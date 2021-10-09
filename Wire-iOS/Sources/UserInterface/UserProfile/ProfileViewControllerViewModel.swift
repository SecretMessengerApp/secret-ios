
import Foundation
import WireDataModel
import WireSystem

private let zmLog = ZMSLog(tag: "ProfileViewControllerViewModel")

enum ProfileViewControllerContext {
    case search
    case groupConversation
    case oneToOneConversation
    case deviceList
    /// when opening from a URL scheme, not linked to a specific conversation
    case profileViewer
}

final class ProfileViewControllerViewModel: NSObject {
    let bareUser: UserType
    let conversation: ZMConversation?
    let viewer: UserType
    let context: ProfileViewControllerContext
    
    weak var delegate: ProfileViewControllerDelegate? {
        didSet {
            backButtonTitleDelegate = delegate as? BackButtonTitleDelegate
        }
    }

    
    weak var backButtonTitleDelegate: BackButtonTitleDelegate?
    
    private var observerToken: Any?
    weak var viewModelDelegate: ProfileViewControllerViewModelDelegate?

    init(
        bareUser: UserType,
        conversation: ZMConversation?,
        viewer: UserType,
        context: ProfileViewControllerContext
    ) {
        self.bareUser = bareUser
        self.conversation = conversation
        self.viewer = viewer
        self.context = context

        super.init()
        
        if let fullUser = fullUser,
           let userSession = ZMUserSession.shared() {
            observerToken = UserChangeInfo.add(observer: self, for: fullUser, userSession: userSession)
        }
    }
    
    var fullUser: ZMUser? {
        return (bareUser as? ZMUser) ?? (bareUser as? ZMSearchUser)?.user
    }

    var hasLegalHoldItem: Bool {
        return bareUser.isUnderLegalHold || conversation?.isUnderLegalHold == true
    }
    
    var shouldShowVerifiedShield: Bool {
        // TODO: ToSwift bareUser.isVerified && context != .deviceList
        guard let selfUser = ZMUser.selfUser(), let user = fullUser else { return false }
        return user.trusted() && selfUser.trusted() && !user.clients.isEmpty && context != .deviceList
    }
    
    var hasUserClientListTab: Bool {
        nil != fullUser && context != .search && context != .profileViewer
    }
    
    var fullUserSet: UserSet {
        if let fullUser = fullUser {
            return UserSet(arrayLiteral: fullUser)
        } else {
            return UserSet()
        }
    }
    
    var incomingRequestFooterHidden: Bool {
        return !bareUser.isPendingApprovalBySelfUser
    }
    
    var blockTitle: String? {
        return BlockResult.title(for: bareUser)
    }
    
    var allBlockResult: [BlockResult] {
        return BlockResult.all(isBlocked: bareUser.isBlocked)
    }
    
    func cancelConnectionRequest(completion: @escaping Completion) {
        let user = fullUser
        ZMUserSession.shared()?.enqueueChanges({
            user?.cancelConnectionRequest()
            completion()
        })
    }
    
    func toggleBlocked() {
        fullUser?.toggleBlocked()
    }
    
    func openOneToOneConversation() {
        guard let fullUser = fullUser else {
            zmLog.error("No user to open conversation with")
            return
        }
        var conversation: ZMConversation? = nil
        
        ZMUserSession.shared()?.enqueueChanges({
            conversation = fullUser.oneToOneConversation
        }, completionHandler: {
            guard let conversation = conversation else { return }
            
            self.delegate?.profileViewController(self.viewModelDelegate as? ProfileViewController,
                                                 wantsToNavigateTo: conversation)
        })
    }
    
    // MARK: - Action Handlers
    
    func archiveConversation() {
        transitionToListAndEnqueue {
            self.conversation?.isArchived.toggle()
        }
    }
    
    func handleBlockAndUnblock() {
        switch context {
        case .search:
            /// stay on this VC and let user to decise what to do next
            enqueueChanges(toggleBlocked)
        default:
            transitionToListAndEnqueue { self.toggleBlocked() }
        }
    }

    // MARK: - Notifications
    
    func updateMute(enableNotifications: Bool) {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation?.mutedMessageTypes = enableNotifications ? .none : .all
            // update the footer view to display the correct mute/unmute button
            self.viewModelDelegate?.updateFooterViews()
        }
    }
    
    func handleNotificationResult(_ result: NotificationResult) {
        if let mutedMessageTypes = result.mutedMessageTypes {
            ZMUserSession.shared()?.performChanges {
                self.conversation?.mutedMessageTypes = mutedMessageTypes
            }
        }
    }

    // MARK: Delete Contents

    func handleDeleteResult(_ result: ClearContentResult) {
        guard case .delete(leave: let leave) = result else { return }
        transitionToListAndEnqueue {
            self.conversation?.clearMessageHistory()
            if leave {
                self.conversation?.removeOrShowError(participnant: ZMUser.selfUser())
            }
        }
    }


    // MARK: - Helpers
    
    func transitionToListAndEnqueue(leftViewControllerRevealed: Bool = true, _ block: @escaping () -> Void) {
        ZClientViewController.shared?.transitionToList(animated: true,
                                                       leftViewControllerRevealed: leftViewControllerRevealed) {
                                                        self.enqueueChanges(block)
        }
    }
    
    func enqueueChanges(_ block: @escaping () -> Void) {
        ZMUserSession.shared()?.enqueueChanges(block)
    }

    // MARK: - Factories
    
    func makeUserNameDetailViewModel() -> UserNameDetailViewModel {
        return UserNameDetailViewModel(user: bareUser, fallbackName: bareUser.name ?? "", addressBookName: fullUser?.addressBookEntry?.cachedName)
    }
    
    var profileActionsFactory: ProfileActionsFactory {
        return ProfileActionsFactory(user: bareUser, viewer: viewer, conversation: conversation, context: context)
    }
    
    // MARK: Connect
    
    func sendConnectionRequest() {
        let connect: (String) -> Void = {
            if let user = self.fullUser {
                user.connect(message: $0)
            } else if let searchUser = self.bareUser as? ZMSearchUser {
                searchUser.connect(message: $0)
            }
        }
        
        ZMUserSession.shared()?.enqueueChanges {
            let messageText = "missive.connection_request.default_message".localized(args: self.bareUser.name ?? "", self.viewer.name ?? "")
            connect(messageText)
            // update the footer view to display the cancel request button
            self.viewModelDelegate?.updateFooterViews()
        }
    }
    
    func acceptConnectionRequest() {
        guard let user = self.fullUser else { return }
        ZMUserSession.shared()?.enqueueChanges {
            user.accept()
            user.refreshData()
            self.viewModelDelegate?.updateFooterViews()
        }
    }
    
    func ignoreConnectionRequest() {
        guard let user = self.fullUser else { return }
        ZMUserSession.shared()?.enqueueChanges {
            user.ignore()
            self.viewModelDelegate?.returnToPreviousScreen()
        }
    }

}

extension ProfileViewControllerViewModel: ZMUserObserver {
    func userDidChange(_ note: UserChangeInfo) {
        if note.trustLevelChanged {
            viewModelDelegate?.updateShowVerifiedShield()
        }
        
        if note.legalHoldStatusChanged {
            viewModelDelegate?.setupNavigationItems()
        }

        if note.nameChanged {
            viewModelDelegate?.updateTitleView()
        }
        
        if note.user.isAccountDeleted {
            viewModelDelegate?.updateFooterViews()
        }
    }
}

extension ProfileViewControllerViewModel: BackButtonTitleDelegate {
    func suggestedBackButtonTitle(for controller: ProfileViewController?) -> String? {
        return bareUser.name?.uppercased(with: .current)
    }
}

protocol ProfileViewControllerViewModelDelegate: class {
    func updateShowVerifiedShield()
    func setupNavigationItems()
    func updateFooterViews()
    func updateTitleView()
    func returnToPreviousScreen()
}
