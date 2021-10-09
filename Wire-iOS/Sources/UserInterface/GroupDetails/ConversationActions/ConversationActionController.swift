
import GCDWebServers

final class ConversationActionController {
    
    struct PresentationContext {
        let view: UIView
        let rect: CGRect
    }
    
    enum Context {
        case list, details
    }

    private let conversation: ZMConversation
    unowned let target: UIViewController
    var currentContext: PresentationContext?
    weak var alertController: UIAlertController?
    
    init(conversation: ZMConversation, target: UIViewController) {
        self.conversation = conversation
        self.target = target
    }

    func presentMenu(from sourceView: UIView?, context: Context) {
        currentContext = sourceView.map {
            .init(
                view: target.view,
                rect: target.view.convert($0.frame, from: $0.superview).insetBy(dx: 8, dy: 8)
            )
        }
        
        let actions: [ZMConversation.Action]
        switch context {
        case .details:
            actions = conversation.detailActions
        case .list:
            actions = conversation.listActions
        }
        
        let title = context == .list ? conversation.displayName : nil
        let controller = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        actions.map(alertAction).forEach(controller.addAction)
        controller.addAction(.cancel())
        controller.applyTheme()
        present(controller)
        
        alertController = controller
    }
    
    func transitionToListAndEnqueue(_ block: @escaping () -> Void) {
        ZClientViewController.shared?.transitionToList(animated: true) {
            ZMUserSession.shared()?.enqueueChanges(block)
        }
    }
    
    func enqueue(_ block: @escaping () -> Void) {
        ZMUserSession.shared()?.enqueueChanges(block)
    }

    func handleAction(_ action: ZMConversation.Action) {
        switch action {

        case .deleteGroup:
            guard let userSession = ZMUserSession.shared() else { return }

            requestDeleteGroupResult() { result in
                self.handleDeleteGroupResult(result, conversation: self.conversation, in: userSession)
            }
//        case .archive(isArchived: let isArchived): self.transitionToListAndEnqueue {
//            self.conversation.isArchived = !isArchived
//            }
        case .markRead: self.enqueue {
            self.conversation.markAsRead()
            }
        case .markUnread: self.enqueue {
            self.conversation.markAsUnread()
            }
        case .configureNotifications: self.requestNotificationResult(for: self.conversation) { result in
            self.handleNotificationResult(result, for: self.conversation)
        }
        case .silence(isSilenced: let isSilenced): self.enqueue {
            self.conversation.mutedMessageTypes = isSilenced ? .none : .all 
            }

        case .placeTop(isPlaceTop: let placeTop):
            ZMUserSession.shared()?.enqueueChanges {
                self.conversation.isPlacedTop = !placeTop
            }
        case .notDisturb(isNotDisturb: let notDisturb):
            ZMUserSession.shared()?.enqueueChanges {
                self.conversation.isNotDisturb = !notDisturb
                if !notDisturb {
                    self.conversation.mutedMessageTypes = .regular
                }
            }
        case .shortcut(isShortcut: let shortcut):
            guard let currentAccount = SessionManager.shared?.accountManager.selectedAccount else { return }
            if case .hugeGroup = conversation.conversationType, conversation.isSelfAnActiveMember == false {
                ZMUserSession.shared()?.enqueueChanges {
                    self.conversation.isSelfAnActiveMember = true
                    self.conversation.isArchived = false
                }
            }
            if !shortcut {
                let _ = Settings.shared.setShortcutConversation(conversation, for: currentAccount)
            } else {
                let _ = Settings.shared.removeShortcurConversation(conversation, for: currentAccount)
            }
            MainTabBarController.shared?.setShortcutTabBarItem()
            
        case .addToHomeScreen:
            ConversationAddToHomeScreenController(conversation: conversation).addToHomeScreen()

        case .leave:
            if (self.conversation.creator.isSelfUser && self.conversation.activeParticipants.count != 1) {
                let confirm = AlertView.ActionType.confirm((nil, nil))
                AlertView(with: "meta.leave_conversation_selfIsCreator_dialog_title".localized, confirm: confirm, cancel: nil).show()
                return
            }
            self.request(LeaveResult.self) { result in
                self.handleLeaveResult(result, for: self.conversation)
            }
        case .clearContent: self.requestClearContentResult(for: self.conversation) { result in
            self.handleClearContentResult(result, for: self.conversation)

            }
        case .cancelRequest:
            guard let user = self.conversation.connectedUser else { return }
            self.requestCancelConnectionRequestResult(for: user) { result in
                self.handleConnectionRequestResult(result, for: self.conversation)
            }
        case .block: self.requestBlockResult(for: self.conversation) { result in
            self.handleBlockResult(result, for: self.conversation)
            }
        case .moveToFolder:
            self.openMoveToFolder(for: self.conversation)
        case .removeFromFolder:
            enqueue {
                self.conversation.removeFromFolder()
            }
        case .favorite(isFavorite: let isFavorite):
            enqueue {
                self.conversation.isFavorite = !isFavorite
            }
        case .remove: fatalError()
            
        case .archive: break
        }
    }
    
    private func alertAction(for action: ZMConversation.Action) -> UIAlertAction {
        return action.alertAction { [weak self] in
            guard let `self` = self else { return }
            self.handleAction(action)
        }
    }

    func present(_ controller: UIViewController) {
        present(controller,
                currentContext: currentContext,
                target: target)
    }
    
    private func prepare(viewController: UIViewController, with context: PresentationContext) {
        viewController.popoverPresentationController.apply {
            $0.sourceView = context.view
            $0.sourceRect = context.rect
        }
    }
    
    private func present(_ controller: UIViewController,
                 currentContext: PresentationContext?,
                 target: UIViewController) {
        currentContext.apply {
            prepare(viewController: controller, with: $0)
        }
        target.present(controller, animated: true, completion: nil)
    }
}
