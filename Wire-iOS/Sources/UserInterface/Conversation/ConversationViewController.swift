
import UIKit

final class ConversationViewController: UIViewController {
    
    unowned let zClientViewController: ZClientViewController
    private let session: ZMUserSessionInterface
    private let visibleMessage: ZMConversationMessage?
    
    var navBarContainer: UINavigationBarContainer!
    var navBarContainerHeight: NSLayoutConstraint!
    var navBarHidden: Bool = false
    
    var conversation: ZMConversation {
        didSet {
            if oldValue == conversation {
                return
            }
            update(conversation: conversation)
        }
    }
    
    var isFocused = false
    
    private(set) var startCallController: ConversationCallController!
    
    let contentViewController: ConversationContentViewController
    let inputBarController: ConversationInputBarViewController

    var collectionController: CollectionsViewController?
    var outgoingConnectionViewController: OutgoingConnectionViewController!
    let conversationBarController: BarController = BarController()
    let guestsBarController: GuestsBarController = GuestsBarController()
    let invisibleInputAccessoryView: InvisibleInputAccessoryView = InvisibleInputAccessoryView()
    let mediaBarViewController: MediaBarViewController
    private let titleView: ConversationTitleView

    var inputBarBottomMargin: NSLayoutConstraint?
    var inputBarZeroHeight: NSLayoutConstraint?
    
    var isAppearing = false
    private var voiceChannelStateObserverToken: Any?
    private var conversationObserverToken: Any?
    private var conversationListObserverToken: Any?
    private var onoOnOneConversationObserverToken: Any?
    
    var participantsController: UIViewController? {
        var viewController: UIViewController? = nil
        switch conversation.conversationType {
        case .group, .hugeGroup:
            viewController = GroupDetailsViewController(conversation: conversation)
            let group = viewController as! GroupDetailsViewController
            group.collectionsViewControllerDelegate = self
        case .`self`, .connection:
            viewController = createUserDetailViewController()
        case .oneOnOne:
            if let user = conversation.firstActiveParticipantOtherThanSelf {
                viewController = UserProfileViewController(
                    user: user,
                    connectionConversation: conversation,
                    userProfileViewControllerDelegate: self,
                    collectionsViewControllerDelegate: self,
                    groupConversation: nil,
                    isCreater: false
                )
            }
        case .invalid:
            fatal("Trying to open invalid conversation")
        }
        return viewController?.wrapInNavigationController()
    }
    
    required init(
        session: ZMUserSessionInterface,
        conversation: ZMConversation,
        visibleMessage: ZMMessage?,
        zClientViewController: ZClientViewController
    ) {
        self.session = session
        self.conversation = conversation
        self.visibleMessage = visibleMessage
        self.zClientViewController = zClientViewController
        
        contentViewController = ConversationContentViewController(
            conversation: conversation,
            message: visibleMessage,
            mediaPlaybackManager: zClientViewController.mediaPlaybackManager,
            session: session
        )

        inputBarController = ConversationInputBarViewController(conversation: conversation)

        mediaBarViewController = MediaBarViewController(mediaPlaybackManager: zClientViewController.mediaPlaybackManager)
        
        titleView = ConversationTitleView(conversation: conversation, interactive: true)
        
        super.init(nibName: nil, bundle: nil)
        
        definesPresentationContext = true
        
        update(conversation: conversation)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        dismissCollectionIfNecessary()
        hideAndDestroyParticipantsPopover()
        contentViewController.delegate = nil
    }
    
    private func update(conversation: ZMConversation) {
        setupNavigatiomItem()
        updateOutgoingConnectionVisibility()
        
        voiceChannelStateObserverToken = addCallStateObserver()
        conversationObserverToken = ConversationChangeInfo.add(observer: self, for: conversation)
        startCallController = ConversationCallController(conversation: conversation, target: self)
        
        if  conversation.conversationType == .oneOnOne,
            let connectedUser = conversation.connectedUser,
            let session = session as? ZMUserSession {
            onoOnOneConversationObserverToken = UserChangeInfo.add(
                observer: self,
                for: connectedUser,
                userSession: session
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let session = session as? ZMUserSession {
            conversationListObserverToken = ConversationListChangeInfo.add(observer: self, for: ZMConversationList.conversations(inUserSession: session), userSession: session)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        UIView.performWithoutAnimation {
            self.view.backgroundColor = .dynamic(scheme: .barBackground)
        }
        
        setupInputBarController()
        setupContentViewController()
        
        contentViewController.tableView.pannableView = inputBarController.view
        
        setupMediaBarViewController()
        
        addToSelf(contentViewController)
        addToSelf(inputBarController)
        addToSelf(conversationBarController)
        
        updateOutgoingConnectionVisibility()
        createConstraints()
        updateInputBarVisibility()
        
        if let quote = conversation.draftMessage?.quote, !quote.hasBeenDeleted {
            inputBarController.addReplyComposingView(contentViewController.createReplyComposingView(for: quote))
        }
        
        createNavBarContainer()
    }
    
    func createOutgoingConnectionViewController() {
        outgoingConnectionViewController = OutgoingConnectionViewController()
        outgoingConnectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        outgoingConnectionViewController.buttonCallback = { [weak self] action in
            self?.session.enqueueChanges {
                switch action {
                case .cancel:
                    self?.conversation.connectedUser?.cancelConnectionRequest()
                case .archive:
                    self?.conversation.isArchived = true
                }
            }
            
            self?.openConversationList()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isAppearing = true
        updateGuestsBarVisibility()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        updateGuestsBarVisibility()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateLeftNavigationBarItems()
        ZMUserSession.shared()?.didClose(conversation: conversation)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        updateLeftNavigationBarItems()
    }
    
    func scroll(to message: ZMConversationMessage?) {
        contentViewController.scroll(to: message, completion: nil)
    }
    
    // MARK: - Device orientation
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { context in
            self.updateLeftNavigationBarItems()
        }
        
        super.viewWillTransition(to: size, with: coordinator)
        
        hideAndDestroyParticipantsPopover()
    }
    
    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        self.updateLeftNavigationBarItems()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        if collectionController?.view.window == nil {
            collectionController = nil
        }
    }
    
    func openConversationList() {
        guard let leftControllerRevealed = wr_splitViewController?.isLeftViewControllerRevealed else { return }
        wr_splitViewController?.setLeftViewControllerRevealed(!leftControllerRevealed, animated: true, completion: nil)
    }
    
    // MARK: - Getters, setters
    
    func setCollection(_ collectionController: CollectionsViewController?) {
        self.collectionController = collectionController
        updateLeftNavigationBarItems()
    }
    
    // MARK: - Application Events & Notifications
    override func accessibilityPerformEscape() -> Bool {
        openConversationList()
        return true
    }
    
    @objc
    func onBackButtonPressed(_ backButton: UIButton?) {
        openConversationList()
    }

    private func setupContentViewController() {
        contentViewController.delegate = self
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentViewController.bottomMargin = 16
        inputBarController.mentionsView = contentViewController.mentionsSearchResultsViewController
        contentViewController.mentionsSearchResultsViewController.delegate = inputBarController
    }
    
    private func setupMediaBarViewController() {
        mediaBarViewController.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapMediaBar(_:))))
    }
    
    @objc
    func didTapMediaBar(_ tapGestureRecognizer: UITapGestureRecognizer?) {
        if let mediaPlayingMessage = AppDelegate.shared.mediaPlaybackManager?.activeMediaPlayer?.sourceMessage,
            conversation == mediaPlayingMessage.conversation {
            contentViewController.scroll(to: mediaPlayingMessage, completion: nil)
        }
    }
    
    private func setupInputBarController() {
        inputBarController.delegate = self
        inputBarController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Create an invisible input accessory view that will allow us to take advantage of built in keyboard
        // dragging and sizing of the scrollview
        invisibleInputAccessoryView.delegate = self
        invisibleInputAccessoryView.isUserInteractionEnabled = false // make it not block touch events
        invisibleInputAccessoryView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        if !AutomationHelper.sharedHelper.disableInteractiveKeyboardDismissal {
            inputBarController.inputBar.invisibleInputAccessoryView = invisibleInputAccessoryView
        }
    }
    
    private func updateInputBarVisibility() {
        // TODO: ToSwift "11111111-0000-0000-0000-000000000002"
        if conversation.isReadOnly ||
            conversation.conversationType == .connection {
            inputBarController.inputBar.textView.resignFirstResponder()
            inputBarController.dismissMentionsIfNeeded()
            inputBarController.removeReplyComposingView()
            
            inputBarController.inputBar.isHidden = true
            inputBarZeroHeight?.isActive = true
        } else {
            inputBarController.inputBar.isHidden = false
            inputBarZeroHeight?.isActive = false
        }
        
        view.setNeedsLayout()
    }
    
    private func setupNavigatiomItem() {
        titleView.tapHandler = { [weak self] button in
            if let superview = self?.titleView.superview,
                let participantsController = self?.participantsController {
                self?.presentParticipantsViewController(participantsController, from: superview)
            }
        }
        titleView.configure()
        
        navigationItem.titleView = titleView
        navigationItem.leftItemsSupplementBackButton = false
        
        updateLeftNavigationBarItems()
        updateRightNavigationItemsButtons()
    }
    
    
    //MARK: - ParticipantsPopover
    
    private func hideAndDestroyParticipantsPopover() {
        if  presentedViewController is GroupDetailsViewController ||
            presentedViewController is ProfileViewController {
            dismiss(animated: true)
        }
    }
}

//MARK: - InvisibleInputAccessoryViewDelegate

extension ConversationViewController: InvisibleInputAccessoryViewDelegate {

    // WARNING: DO NOT TOUCH THIS UNLESS YOU KNOW WHAT YOU ARE DOING
    func invisibleInputAccessoryView(_ invisibleInputAccessoryView: InvisibleInputAccessoryView, superviewFrameChanged frame: CGRect?) {
        // Adjust the input bar distance from bottom based on the invisibleAccessoryView
        var distanceFromBottom: CGFloat = 0

        // On iOS 8, the frame goes to zero when the accessory view is hidden
        if frame?.equalTo(.zero) == false {

            let convertedFrame = view.convert(invisibleInputAccessoryView.superview?.frame ?? .zero, from: invisibleInputAccessoryView.superview?.superview)

            // We have to use intrinsicContentSize here because the frame may not have actually been updated yet
            let newViewHeight = invisibleInputAccessoryView.intrinsicContentSize.height

            distanceFromBottom = view.frame.size.height - convertedFrame.origin.y - newViewHeight

            distanceFromBottom = max(0, distanceFromBottom)
        }

        let closure: () -> Void = {
            self.inputBarBottomMargin?.constant = -distanceFromBottom
            self.view.layoutIfNeeded()
        }

        if isAppearing {
            UIView.performWithoutAnimation(closure)
        } else {
            closure()
        }
    }
}

//MARK: - ZMConversationObserver

extension ConversationViewController: ZMConversationObserver {
    public func conversationDidChange(_ note: ConversationChangeInfo) {
        if note.causedByConversationPrivacyChange {
            presentPrivacyWarningAlert(for: note)
        }
        
        if note.participantsChanged || note.connectionStateChanged {
            updateRightNavigationItemsButtons()
            updateLeftNavigationBarItems()
            updateOutgoingConnectionVisibility()
            // TODO: ToSwift updateTableViewHeaderView()
//            contentViewController.updateTableViewHeaderView()
            updateInputBarVisibility()
        }
        
//        if note.participantsChanged || note.externalParticipantsStateChanged {
//            updateGuestsBarVisibility()
//        }
        
        if  note.nameChanged ||
            note.securityLevelChanged ||
            note.connectionStateChanged ||
            note.legalHoldStatusChanged ||
            note.replyTypeChanged ||
            note.disableSendMsgChanged {
            setupNavigatiomItem()
        }
        
        if note.announcementChanged {
            contentViewController.showTopRemindView(with: .announcement, isHidden: navBarHidden)
        }
        
        if note.blockWarningMessageChanged {
            contentViewController.showTopRemindView(with: .blockWarning, isHidden: navBarHidden)
            if isAppearing {
                contentViewController.updateVisibleMessagesWindow()
            }
        }
        

    }
    
    func dismissProfileClientViewController(_ sender: UIBarButtonItem?) {
        dismiss(animated: true)
    }
}

//MARK: - ZMConversationListObserver

extension ConversationViewController: ZMConversationListObserver {
    public func conversationListDidChange(_ changeInfo: ConversationListChangeInfo) {
        updateLeftNavigationBarItems()
        if changeInfo.deletedObjects.contains(conversation) {
            ZClientViewController.shared?.transitionToList(animated: true, completion: nil)
        }
    }
    
    public func conversationInsideList(_ list: ZMConversationList, didChange changeInfo: ConversationChangeInfo) {
        updateLeftNavigationBarItems()
    }
}

//MARK: - InputBar

extension ConversationViewController: ConversationInputBarViewControllerDelegate {
    
    func conversationInputBarViewControllerDidComposeText(
        text: String,
        mentions: [Mention],
        replyingTo message: ZMConversationMessage?
    ) {
        contentViewController.scrollToBottom()
        inputBarController.sendController.sendTextMessage(text, mentions: mentions, replyingTo: message, isMarkDown: self.inputBarController.inputBar.isMarkingDown)
    }
    
    func conversationInputBarViewControllerShouldBeginEditing(_ controller: ConversationInputBarViewController) -> Bool {
        if  !contentViewController.isScrolledToBottom
            && !controller.isEditingMessage
            && !controller.isReplyingToMessage {
            collectionController = nil
            contentViewController.searchQueries = []
            contentViewController.scrollToBottom()
        }
//        setGuestBarForceHidden(true)
        return true
    }
    
    func conversationInputBarViewControllerShouldEndEditing(_ controller: ConversationInputBarViewController) -> Bool {
//        setGuestBarForceHidden(false)
        return true
    }
    
    func conversationInputBarViewControllerDidFinishEditing(
        _ message: ZMConversationMessage,
        withText newText: String?,
        mentions: [Mention]
    ) {
        contentViewController.didFinishEditing(message)
        session.enqueueChanges({
            if let newText = newText, !newText.isEmpty {
                var fetchLinkPreview = !Settings.disableLinkPreviews
                guard let msg = message as? ZMMessage else {
                    return
                }
                if self.conversation.conversationType == .hugeGroup || msg.quote != nil || msg.translationText != nil {
                    fetchLinkPreview = false
                }
                message.textMessageData?.editText(newText, mentions: mentions, fetchLinkPreview: fetchLinkPreview)
            } else {
                ZMMessage.deleteForEveryone(message)
            }
        })
    }
    
    func conversationInputBarViewControllerDidCancelEditing(_ message: ZMConversationMessage) {
        contentViewController.didFinishEditing(message)
    }
    
    func conversationInputBarViewControllerWants(toShow message: ZMConversationMessage) {
        contentViewController.scroll(to: message) { cell in
            self.contentViewController.highlight(message)
        }
    }
    
    func conversationInputBarViewControllerEditLastMessage() {
        contentViewController.editLastMessage()
    }

    func conversationInputBarViewControllerDidComposeDraft(message: DraftMessage) {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation.draftMessage = message
        }
    }
}


// MARK: - ZMUserObserver

extension ConversationViewController: ZMUserObserver {
    
    func userDidChange(_ changeInfo: UserChangeInfo) {
  
        if changeInfo.nameChanged || changeInfo.remarkChanged {
            setupNavigatiomItem()
        }
    }
}
