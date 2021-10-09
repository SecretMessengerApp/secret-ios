//
//  UserProfileViewController.swift
//  Wire-iOS
//

import UIKit
import Cartography

@objc protocol UserProfileViewControllerDelegate {


    @objc optional func wantToCreateConversationWithName(_ name: String, users: Set<ZMUser>)


    @objc optional func wantToConversationRecordWithConversation(_ conversation: ZMConversation)

    /// - Parameter conversation:
    @objc optional func wantsToNavigateToConversation(_ conversation: ZMConversation)
}

final internal class UserProfileViewController: UIViewController {
    private var user: ZMUser
    private var connectionConversation: ZMConversation?
    private var groupConversation: ZMConversation?
    private let settingsController: SettingsTableViewController
    private var userProfileAccountView: UserProfileAccountView!
    internal var settingsCellDescriptorFactory: SettingsCellDescriptorFactory?
    internal var rootGroup: (SettingsControllerGeneratorType & SettingsInternalGroupCellDescriptorType)?
    internal var isCreater: Bool = false

    weak var delegate: UserProfileViewControllerDelegate?
    fileprivate var observerToken: Any! = nil

    weak var collectionsViewControllerDelegate: CollectionsViewControllerDelegate?

    ///
    ///
    /// - Parameters:
    ///   - user:
    ///   - conversation:
    ///   - userProfileViewControllerDelegate:
    ///   - groupConversation:
    ///   - isCreater:
    convenience init(
        user: ZMUser,
        connectionConversation: ZMConversation? = nil,
        userProfileViewControllerDelegate: UserProfileViewControllerDelegate? = nil,
        collectionsViewControllerDelegate: CollectionsViewControllerDelegate? = nil,
        groupConversation: ZMConversation? = nil,
        isCreater: Bool = false
    ) {
        let settingsPropertyFactory = SettingsPropertyFactory(userSession: SessionManager.shared?.activeUserSession,
                                                              selfUser: user,
                                                              conversation: connectionConversation,
                                                              groupConversation: groupConversation)

        let settingsCellDescriptorFactory = SettingsCellDescriptorFactory(settingsPropertyFactory: settingsPropertyFactory)
        let rootGroup = settingsCellDescriptorFactory.userProfileGroup(isCreater, groupConversation: groupConversation)
        self.init(user: user, settingsCellDescriptorFactory: settingsCellDescriptorFactory, rootGroup: rootGroup, userProfileViewControllerDelegate: userProfileViewControllerDelegate)
        self.connectionConversation = connectionConversation
        self.groupConversation = groupConversation
        self.collectionsViewControllerDelegate = collectionsViewControllerDelegate
        self.isCreater = isCreater

        settingsPropertyFactory.delegate = self

    }

    init(user: ZMUser,
         settingsCellDescriptorFactory: SettingsCellDescriptorFactory,
         rootGroup: SettingsControllerGeneratorType & SettingsInternalGroupCellDescriptorType,
         userProfileViewControllerDelegate: UserProfileViewControllerDelegate? = nil) {
        self.user = user
        self.settingsCellDescriptorFactory = settingsCellDescriptorFactory
        self.rootGroup = rootGroup
        settingsController = rootGroup.generateViewController()! as! SettingsTableViewController
        self.delegate = userProfileViewControllerDelegate
        super.init(nibName: .none, bundle: .none)
        settingsController.delegate = self
        if let conv = user.connection?.conversation {
           observerToken = ConversationChangeInfo.add(observer: self, for: conv)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.dynamic(scheme: .barBackground)
        userProfileAccountView = UserProfileAccountView.init(user: user)
        view.addSubview(userProfileAccountView)
        settingsController.willMove(toParent: self)
        view.addSubview(settingsController.view)
        addChild(settingsController)

//        self.navigationItem.rightBarButtonItem = navigationController?.closeItem()
        settingsController.view.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        settingsController.view.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        settingsController.tableView.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        settingsController.tableView.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        setupNavigationItems()
        createConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func accessibilityPerformEscape() -> Bool {
        dismiss()
        return true
    }

    private func dismiss() {
        dismiss(animated: true)
    }

    private func setupNavigationItems() {
        if navigationController?.viewControllers.count == 1 {
            self.navigationItem.rightBarButtonItem = navigationController?.closeItem()
        }
    }

    private func createConstraints() {

        // Sometimes (i.e. after coming from background) the cells are not loaded yet. Reloading to calculate correct height.
        settingsController.tableView.reloadData()
        //        let height = CGFloat(56 * settingsController.tableView.numberOfRows(inSection: 0))

        constrain(view, userProfileAccountView, settingsController.view, settingsController.tableView) { view, userProfileAccountView, settingsControllerView, tableView in
            userProfileAccountView.top == view.top
            userProfileAccountView.leading == view.leading
            userProfileAccountView.trailing == view.trailing
            userProfileAccountView.height == 86

            settingsControllerView.top == userProfileAccountView.bottom
            settingsControllerView.leading == view.leading
            settingsControllerView.trailing == view.trailing
            settingsControllerView.bottom == view.bottom
            //                - UIScreen.safeArea.bottom - 49

            tableView.edges == settingsControllerView.edges
        }
    }

    @objc func userDidTapProfileImage(sender: UserImageViewForSecret) {
        let profileImageController = ProfileSelfPictureViewController(context: .selfUser(ZMUser.selfUser()?.previewImageData))
        self.present(profileImageController, animated: true, completion: .none)
    }

}

extension UserProfileViewController: ZMConversationObserver {
    func conversationDidChange(_ changeInfo: ConversationChangeInfo) {
        guard changeInfo.destructionTimeoutChanged else {
            return
        }
        let rootGroup = self.settingsCellDescriptorFactory?.userProfileGroup(self.isCreater)
        guard let group = rootGroup else {return}
        settingsController.group = group
    }
}

extension UserProfileViewController: SettingsPropertyFactoryDelegate {
    func asyncMethodDidStart(_ settingsPropertyFactory: SettingsPropertyFactory) {
        self.navigationController?.topViewController?.showLoadingView = true
    }

    func asyncMethodDidComplete(_ settingsPropertyFactory: SettingsPropertyFactory) {
        self.navigationController?.topViewController?.showLoadingView = false
    }

}

extension UserProfileViewController: ConversationSettingsTableViewControllerDelegate {
    func onClickCreateConversationCell() {

        let selectedUsers: Set = [user]

        let conversationCreationController = ConversationCreationController.init(preSelectedParticipants: selectedUsers)
        conversationCreationController.delegate = self
//
        if UIScreen.main.traitCollection.horizontalSizeClass == .regular {
            self.dismiss(animated: true) {
                let presentedViewController = conversationCreationController.wrapInNavigationController()

                presentedViewController.modalPresentationStyle = .formSheet

                ZClientViewController.shared?.present(presentedViewController, animated: true, completion: nil)
            }
        } else {
            let avoiding = KeyboardAvoidingViewController.init(viewController: conversationCreationController)
            let presentedViewController = avoiding.wrapInNavigationController()

            presentedViewController.modalPresentationStyle = .currentContext
            presentedViewController.modalTransitionStyle = .coverVertical

            self.parent?.present(presentedViewController, animated: true) {
                //UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(true)
            }
        }
    }

    func onClickConversationRecordCell() {
        guard let conversation = connectionConversation else { return }
        presentConversationRecordWithConversation(conversation)
    }

    func presentConversationRecordWithConversation(_ conversation: ZMConversation) {
        let collections = CollectionsViewController(conversation: conversation)
        collections.delegate = self
        collections.onDismiss = { cols in
            cols.dismiss(animated: true, completion: nil)
        }
        collections.shouldTrackOnNextOpen = true
        let navigationController = KeyboardAvoidingViewController(viewController: collections).wrapInNavigationController(RotationAwareNavigationController.self)
        self.present(navigationController, animated: true, completion: nil)
    }

    func onClickRemoveParticipantCell() {
        guard let conversation = groupConversation else { return }
        self.presentRemoveDialogue(for: user, from: conversation, dismisser: self) {[weak self] in
            guard conversation.conversationType == .hugeGroup,
                let `self` = self else { return }
            if let bgpMemberVC = self.navigationController?.viewControllers.first(where: { return $0 is GroupParticipantsDetailViewController
            }), let vc = bgpMemberVC as? GroupParticipantsDetailViewController {
                vc.removeParticipant(with: self.user)
            }
        }
    }

    func onClickStartChatCell() {
        var conversation: ZMConversation?
        ZMUserSession.shared()?.enqueueChanges({
            conversation = self.user.oneToOneConversation
        }, completionHandler: {
            guard let conversation = conversation else { return }
            self.delegate?.wantsToNavigateToConversation?(conversation)
        })
    }
}

extension UserProfileViewController: ConversationCreationControllerDelegate {
    func conversationCreationController(_ controller: ConversationCreationController,
                                        didSelectName
                                        name: String,
                                        participants: Set<ZMUser>,
                                        allowGuests: Bool) {
        controller.dismiss(animated: true) {
            self.delegate?.wantToCreateConversationWithName?(name, users: participants)
        }
    }
}

extension UserProfileViewController: ViewControllerDismisser {
    func dismiss(viewController: UIViewController, completion: (() -> Void)?) {
        navigationController?.popViewController(animated: true)
    }
}

extension UserProfileViewController: CollectionsViewControllerDelegate {

    func collectionsViewController(_ viewController: UIViewController, performAction: MessageAction, onMessage: ZMConversationMessage) {
        viewController.dismissIfNeeded(animated: true, completion: { [weak self] in
            guard let self = self else {return}
            self.collectionsViewControllerDelegate?.collectionsViewController(self, performAction: performAction, onMessage: onMessage)
        })
    }

}
