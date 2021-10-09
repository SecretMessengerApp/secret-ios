
import UIKit
import Cartography

class GroupDetailsViewController: UIViewController, ZMConversationObserver, GroupDetailsFooterViewDelegate {
    
    struct PresentationContext {
        let view: UIView
        let rect: CGRect
    }
    
    enum GroupDetailsViewControllerSourceType {
        case conversation, group
    }
    
    weak var collectionsViewControllerDelegate: CollectionsViewControllerDelegate?
    
    fileprivate let collectionViewController: SectionCollectionViewController
    internal let conversation: ZMConversation
    fileprivate let footerView = GroupDetailsFooterView()
    fileprivate var token: NSObjectProtocol?
    var actionController: ConversationActionController?
    private var currentContext: PresentationContext?
    fileprivate var renameGroupSectionController: RenameGroupSectionController?
    private var syncObserver: InitialSyncObserver!
    

    var sourceType: GroupDetailsViewControllerSourceType = .conversation
    var didCompleteInitialSync = false {
        didSet {
            collectionViewController.sections = computeVisibleSections()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return wr_supportedInterfaceOrientations
    }

    @objc
    public init(conversation: ZMConversation) {
        self.conversation = conversation
        collectionViewController = SectionCollectionViewController()
        super.init(nibName: nil, bundle: nil)
        token = ConversationChangeInfo.add(observer: self, for: conversation)

        createSubviews()

        if let session = ZMUserSession.shared() {
            syncObserver = InitialSyncObserver(in: session) { [weak self] completed in
                self?.didCompleteInitialSync = completed
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("GroupDetailsViewController-deinit")
    }
    
    
    func createSubviews() {
        let collectionView = UICollectionView(forGroupedSections: ())
        collectionView.accessibilityIdentifier = "group_details.list"

        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }

        [collectionView, footerView].forEach(view.addSubview)

        constrain(view, collectionView, footerView) { container, collectionView, footerView in
            collectionView.top == container.top
            collectionView.leading == container.leading
            collectionView.trailing == container.trailing
            collectionView.bottom == footerView.top
            footerView.leading == container.leading
            footerView.trailing == container.trailing
            footerView.bottom == container.bottom
        }

        collectionViewController.collectionView = collectionView
        footerView.delegate = self
        footerView.update(for: conversation)
        collectionViewController.sections = computeVisibleSections()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "participants.title".localized.uppercased()
        view.backgroundColor = .dynamic(scheme: .groupBackground)
        
        self.getInviteUrl() {
            self.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateLegalHoldIndicator()
        navigationItem.rightBarButtonItem = navigationController?.closeItem()
        collectionViewController.collectionView?.reloadData()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            self.collectionViewController.collectionView?.collectionViewLayout.invalidateLayout()
        })
    }

    func updateLegalHoldIndicator() {
        navigationItem.leftBarButtonItem = conversation.isUnderLegalHold ? legalholdItem : nil
    }

    func computeVisibleSections() -> [CollectionViewSectionController] {
        var sections = [CollectionViewSectionController]()
        let renameGroupSectionController = RenameGroupSectionController(conversation: conversation)
        sections.append(renameGroupSectionController)
        var (participants, serviceUsers) = (conversation.sortedOtherParticipants, conversation.sortedServiceUsers)
        
  
        let isManager = conversation.manager?.contains(ZMUser.selfUser()!.remoteIdentifier.transportString()) ?? false
        if ((self.conversation.creator.isSelfUser || isManager) ||
                (!self.conversation.creator.isSelfUser && self.conversation.isAllowViewMembers)) {
            
            if let managersID = conversation.manager {
                let managers = participants.filter { managersID.contains(($0 as! ZMUser).remoteIdentifier.transportString()) }
                participants = participants.filter { !managersID.contains(($0 as! ZMUser).remoteIdentifier.transportString()) }
                participants.insert(contentsOf: managers, at: 0)
            }
            
            if !self.conversation.creator.isSelfUser {
                participants = participants.filter { ($0 as! ZMUser) != self.conversation.creator }
                participants.insert(self.conversation.creator, at: 0)
            }
            
            participants.insert(ZMUser.selfUser(), at: 0)
            let participantsSectionController = ParticipantsSectionController(participants: participants, conversation: conversation, delegate: self)
            sections.append(participantsSectionController)
        }
        
        let optionsSectionController = GroupOptionsSectionController(conversation: conversation, delegate: self, syncCompleted: didCompleteInitialSync, source: sourceType)
        if optionsSectionController.hasOptions {
            sections.append(optionsSectionController)
        }
        
        if !serviceUsers.isEmpty {
            let servicesSection = ServicesSectionController(serviceUsers: serviceUsers, conversation: conversation, delegate: self)
            sections.append(servicesSection)
        }
        
        return sections
    }
    
    func conversationDidChange(_ changeInfo: ConversationChangeInfo) {
        
        if changeInfo.placeTopStatusChanged || changeInfo.notDisturbStatusChanged {
            reloadData()
        }
        
        guard
            changeInfo.participantsChanged ||
            changeInfo.nameChanged ||
            changeInfo.allowGuestsChanged ||
            changeInfo.destructionTimeoutChanged ||
            changeInfo.mutedMessageTypesChanged ||
            changeInfo.openUrlChanged ||
            changeInfo.selfRemarkChanged ||
            changeInfo.previewAvatarDataChanged ||
            changeInfo.allowViewMembers ||
            changeInfo.announcementChanged ||
            changeInfo.managersChanged ||
            changeInfo.groupCreatorChanged ||
            changeInfo.onlyCreatorInviteChanged ||
            changeInfo.groupTypeChanged ||
            changeInfo.showMemsumChanged ||
            changeInfo.isOpenScreenShotChanged
            else { return }
        
        updateLegalHoldIndicator()
        collectionViewController.sections = computeVisibleSections()
        footerView.update(for: conversation)
        
        if changeInfo.participantsChanged, !conversation.isSelfAnActiveMember {
           navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func footerView(_ view: GroupDetailsFooterView, shouldPerformAction action: GroupDetailsFooterView.Action) {
        switch action {
        case .invite:
            let addParticipantsViewController = AddParticipantsViewController(conversation: conversation)
        
            self.navigationController?.pushViewController(addParticipantsViewController, animated: true)
        case .more:
            actionController = ConversationActionController(conversation: conversation, target: self)
            actionController?.presentMenu(from: view, context: .details)
        }
    }
    
    @objc(presentParticipantsDetailsWithUsers:selectedUsers:animated:)
    func presentParticipantsDetails(with users: [UserType], selectedUsers: [UserType], animated: Bool) {
        let detailsViewController = GroupParticipantsDetailViewController(
            participants: users,
            selectedParticipants: selectedUsers,
            conversation: conversation
        )

        detailsViewController.delegate = self
        navigationController?.pushViewController(detailsViewController, animated: animated)
    }

    func present(_ controller: UIViewController) {
        currentContext.apply {
            prepare(viewController: controller, with: $0)
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    private func prepare(viewController: UIViewController, with context: PresentationContext) {
        viewController.popoverPresentationController.apply {
            $0.sourceView = context.view
            $0.sourceRect = context.rect
        }
    }
    
    func transitionToListAndEnqueue(_ block: @escaping () -> Void) {
        ZClientViewController.shared?.transitionToList(animated: true) {
            ZMUserSession.shared()?.enqueueChanges(block)
        }
    }
    
    func dismissButtonTapped() {
        dismiss(animated: true)
    }
    

}

extension GroupDetailsViewController {
    
    fileprivate var legalholdItem: UIBarButtonItem {
        let item = UIBarButtonItem(icon: .legalholdactive, target: self, action: #selector(presentLegalHoldDetails))
        item.setLegalHoldAccessibility()
        item.tintColor = .vividRed
        return item
    }

    @objc
    func presentLegalHoldDetails() {
        LegalHoldDetailsViewController.present(in: self, conversation: conversation)
    }
    
}

extension GroupDetailsViewController: ViewControllerDismisser, ProfileViewControllerDelegate {
    
    func dismiss(viewController: UIViewController, completion: (() -> ())?) {
        navigationController?.popViewController(animated: true, completion: completion)
    }
    
    func profileViewController(_ controller: ProfileViewController?, wantsToNavigateTo conversation: ZMConversation) {
        dismiss(animated: true) {
            ZClientViewController.shared?.load(conversation, scrollTo: nil, focusOnView: true, animated: true)
        }
    }
    
    func profileViewController(_ controller: ProfileViewController?, wantsToCreateConversationWithName name: String?, users: UserSet) {
        //no-op
    }
}

extension GroupDetailsViewController: GroupDetailsSectionControllerDelegate, GroupOptionsSectionControllerDelegate {
    
    func addToHomeScreen(conversation: ZMConversation) {
        ConversationAddToHomeScreenController(conversation: conversation).addToHomeScreen()
    }
    
    func pushAnnouncementOptions(conversation: ZMConversation, animated: Bool) {
        if conversation.creator.isSelfUser {
            let vc = ConversationAnnouncementViewController(conversation: conversation)
            navigationController?.pushViewController(vc, animated: animated)
        } else {
            if let announcement = conversation.announcement, !announcement.isEmpty {
                let vc = ConversationAnnouncementViewController(conversation: conversation)
                navigationController?.pushViewController(vc, animated: animated)
            } else {
                showAlert(message: "conversation_announcement.alert.no_announcement".localized)
            }
        }
    }
   
    func presentGroupUrlOptions() {
        guard let shareUrl = conversation.joinGroupUrl else { return }
        let cnv = conversation
        HUD.loading(isMask: false)
        ZMUserSession.shared()?.searchContacts { [weak self] contacts in
            let vc = GroupUrlShareViewController(conversation: cnv, shareUrl: shareUrl, contacts: contacts)
            self?.present(vc)
        }
    }
    
    func presentGroupQRCodeOptions() {
        let vc = QRCodeDisplayViewController(context: .group(conversation: conversation))
        navigationController?.pushViewController(vc, animated: true)
    }
    

    func presentDetails(for user: UserType) {
        
        func presentUserProfileVC(user: ZMUser) {
            let viewController = UserProfileViewController(
                user: user,
                connectionConversation: user.connection?.conversation,
                userProfileViewControllerDelegate: self,
                groupConversation: conversation,
                isCreater: conversation.creator.isSelfUser)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
        if let user = user as? ZMUser  {
            presentUserProfileVC(user: user)
        } else if let user = user as? ConversationBGPMemberModel {
            ZMUser.createUserIfNeededWithRemoteID(user.id) { (user) in
                if let user = user {
                    presentUserProfileVC(user: user)
                }
            }
        }
        
    }
    
    
    
    func presentFullParticipantsList(for users: [UserType], in conversation: ZMConversation) {
        presentParticipantsDetails(with: users, selectedUsers: [], animated: true)
    }
    
    func callbackWhenUsersUpdate() {
        self.collectionViewController.collectionView?.reloadSections(NSIndexSet.init(index: 1) as IndexSet)
    }
    
    @objc(presentGuestOptionsWithAnimated:)
    func presentGuestOptions(animated: Bool) {
        let menu = ConversationOptionsViewController(conversation: conversation, userSession: .shared()!)
        navigationController?.pushViewController(menu, animated: animated)
    }

    func presentTimeoutOptions(animated: Bool) {
        let menu = ConversationTimeoutOptionsViewController(conversation: conversation, userSession: .shared()!)
        menu.dismisser = self
        navigationController?.pushViewController(menu, animated: animated)
    }
    
    func presentNotificationsOptions(animated: Bool) {
        let menu = ConversationNotificationOptionsViewController(conversation: conversation, userSession: .shared()!)
        menu.dismisser = self
        navigationController?.pushViewController(menu, animated: animated)
    }
}

extension GroupDetailsViewController {
    func reloadData() {
        self.collectionViewController.collectionView?.reloadData()
    }
}

