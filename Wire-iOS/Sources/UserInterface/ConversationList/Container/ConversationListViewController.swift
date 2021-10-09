

import Foundation

enum ConversationListState {
    case conversationList
    case peoplePicker
    case archived
}

final class ConversationListViewController: UIViewController {
    let viewModel: ViewModel
    /// internal View Model
    var state: ConversationListState = .conversationList

    /// private
    private var viewDidAppearCalled = false
    private static let contentControllerBottomInset: CGFloat = 16
    private static let contentControllerTopInset: CGFloat = 44

    /// for NetworkStatusViewDelegate
    var shouldAnimateNetworkStatusView = false

    var startCallToken: Any?

    var pushPermissionDeniedViewController: PermissionDeniedViewController?
    var usernameTakeoverViewController: UserNameTakeOverViewController?

    var createConversationObservers = [Any]()
    
    fileprivate let noConversationLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString.attributedTextForNoConversationLabel
        label.numberOfLines = 0
        label.backgroundColor = .clear
        
        return label
    }()

    let contentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear

        return view
    }()

    let listContentController: ConversationListContentController = {
        let conversationListContentController = ConversationListContentController()
        conversationListContentController.collectionView.contentInset = UIEdgeInsets(top: ConversationListViewController.contentControllerTopInset, left: 0, bottom: ConversationListViewController.contentControllerBottomInset, right: 0)

        return conversationListContentController
    }()

    let bottomBarController: ConversationListBottomBarController = {
        let conversationListBottomBarController = ConversationListBottomBarController()
        conversationListBottomBarController.showArchived = true

        return conversationListBottomBarController
    }()

//    let topBarViewController: ConversationListTopBarViewController
    let topNavView: ConversationListTopNavView = {
        let topNavView = ConversationListTopNavView()
        return topNavView
    }()
    
    let networkStatusViewController: NetworkStatusViewController = {
        let viewController = NetworkStatusViewController()
        return viewController
    }()

    let conversationListContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear

        return view
    }()

    fileprivate let onboardingHint: ConversationListOnboardingHint = {
        let conversationListOnboardingHint = ConversationListOnboardingHint()
        return conversationListOnboardingHint
    }()

    convenience init(account: Account, selfUser: SelfUserType) {
        let viewModel = ConversationListViewController.ViewModel(account: account, selfUser: selfUser)
        
        self.init(viewModel: viewModel)

        viewModel.viewController = self
    }
    
    required init(viewModel: ViewModel) {

        self.viewModel = viewModel

//        topBarViewController = ConversationListTopBarViewController(account: viewModel.account, selfUser: viewModel.selfUser)
        
        super.init(nibName:nil, bundle:nil)

        definesPresentationContext = true

        /// setup UI
        view.addSubview(contentContainer)

        contentContainer.addSubview(onboardingHint)
        contentContainer.addSubview(conversationListContainer)

        setupNoConversationLabel()
        setupListContentController()
//        setupBottomBarController()
        setupTopBar()
        setupNetworkStatusBar()

        createViewConstraints()
//        onboardingHint.arrowPointToView = bottomBarController.startUIButton
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = PassthroughTouchesView(frame: UIScreen.main.bounds)
        view.backgroundColor = .dynamic(scheme: .cellBackground)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        /// update
        hideNoContactLabel(animated: false)

        viewModel.setupObservers()

        listContentController.collectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 1), animated: false)
        
        listContentController.collectionView.addShakeHeaderCallback { [weak self] in
            self?.endRefresh()
        }
        
    }
    
    func endRefresh() {
        delay(0.5) {
            if let header = self.listContentController.collectionView.mj_header {
                header.endRefreshing()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        viewModel.savePendingLastRead()
        viewModel.requestSuggestedHandlesIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !isIPadRegular() {
            Settings.shared[.lastViewedScreen] = SettingsLastScreen.list
        }

        state = .conversationList

        updateBottomBarSeparatorVisibility(with: listContentController)
        closePushPermissionDialogIfNotNeeded()

        shouldAnimateNetworkStatusView = true

        if !viewDidAppearCalled {
            viewDidAppearCalled = true
            ZClientViewController.shared?.showDataUsagePermissionDialogIfNeeded()
            ZClientViewController.shared?.showAvailabilityBehaviourChangeAlertIfNeeded()
            viewModel.updateNoConversationVisibility()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { context in
            // we reload on rotation to make sure that the list cells lay themselves out correctly for the new
            // orientation
            self.listContentController.reload()
        })

        super.viewWillTransition(to: size, with: coordinator)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    // MARK: - setup UI

    fileprivate func setupNoConversationLabel() {
        contentContainer.addSubview(noConversationLabel)
    }

    fileprivate func setupBottomBarController() {
        bottomBarController.delegate = self
        
        add(bottomBarController, to: conversationListContainer)

        listContentController.listViewModel.restorationDelegate = bottomBarController
    }

    fileprivate func setupListContentController() {
        listContentController.contentDelegate = viewModel
        listContentController.hideAnimator = self

        add(listContentController, to: conversationListContainer)
    }
    
    fileprivate func setupTopBar() {
//        add(topBarViewController, to: contentContainer)
        view.addSubview(topNavView)
    }
    
    fileprivate func setupNetworkStatusBar() {
        networkStatusViewController.delegate = self
        addToSelf(networkStatusViewController)
    }

    fileprivate func createViewConstraints() {
        guard /*let bottomBar = bottomBarController.view,*/
            let listContent = listContentController.view
            /*let topBarView = topBarViewController.view*/ else { return }
        
        [conversationListContainer,
//         bottomBar,
         networkStatusViewController.view,
//         topBarView,
         topNavView,
         contentContainer,
         noConversationLabel,
         onboardingHint,
         listContent].forEach() { $0?.translatesAutoresizingMaskIntoConstraints = false }
        
//        let bottomBarBottomOffset = bottomBar.bottomAnchor.constraint(equalTo: bottomBar.superview!.bottomAnchor)
        
        let constraints: [NSLayoutConstraint] = [
            conversationListContainer.topAnchor.constraint(equalTo: conversationListContainer.superview!.topAnchor),
            conversationListContainer.bottomAnchor.constraint(equalTo: conversationListContainer.superview!.bottomAnchor),
            conversationListContainer.leadingAnchor.constraint(equalTo: conversationListContainer.superview!.leadingAnchor),
            conversationListContainer.trailingAnchor.constraint(equalTo: conversationListContainer.superview!.trailingAnchor),
            
//            bottomBar.leftAnchor.constraint(equalTo: bottomBar.superview!.leftAnchor),
//            bottomBar.rightAnchor.constraint(equalTo: bottomBar.superview!.rightAnchor),
//            bottomBarBottomOffset,
            
//            topBarView.leftAnchor.constraint(equalTo: topBarView.superview!.leftAnchor),
//            topBarView.rightAnchor.constraint(equalTo: topBarView.superview!.rightAnchor),
//            topBarView.bottomAnchor.constraint(equalTo: conversationListContainer.topAnchor),
            
            topNavView.topAnchor.constraint(equalTo: view.topAnchor),
            topNavView.leftAnchor.constraint(equalTo: view.leftAnchor),
            topNavView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
//            contentContainer.bottomAnchor.constraint(equalTo: safeBottomAnchor),
//            contentContainer.topAnchor.constraint(equalTo: safeTopAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentContainer.topAnchor.constraint(equalTo: view.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            noConversationLabel.centerXAnchor.constraint(equalTo: noConversationLabel.superview!.centerXAnchor),
            noConversationLabel.centerYAnchor.constraint(equalTo: noConversationLabel.superview!.centerYAnchor),
            noConversationLabel.heightAnchor.constraint(equalToConstant: 120),
            noConversationLabel.widthAnchor.constraint(equalToConstant: 240),
            
            onboardingHint.bottomAnchor.constraint(equalTo: conversationListContainer.bottomAnchor),
            onboardingHint.leftAnchor.constraint(equalTo: onboardingHint.superview!.leftAnchor),
            onboardingHint.rightAnchor.constraint(equalTo: onboardingHint.superview!.rightAnchor),
            
            listContent.topAnchor.constraint(equalTo: listContent.superview!.topAnchor),
            listContent.leadingAnchor.constraint(equalTo: listContent.superview!.leadingAnchor),
            listContent.trailingAnchor.constraint(equalTo: listContent.superview!.trailingAnchor),
            listContent.bottomAnchor.constraint(equalTo: conversationListContainer.bottomAnchor)
        ]
        
        ///TODO: merge this method and activate the constraints in a batch
//        networkStatusViewController.createConstraintsInParentController(bottomView: topBarView, controller: self)
        
        networkStatusViewController.createConstraintsInParentController(bottomView: topNavView.actionContainView, controller: self)
        
        NSLayoutConstraint.activate(constraints)
    }

    func createArchivedListViewController() -> ArchivedListViewController {
        let archivedViewController = ArchivedListViewController()
        archivedViewController.delegate = viewModel
        return archivedViewController
    }

    func showNoContactLabel(animated: Bool = true) {
        if state != .conversationList { return }

        let closure = {
            let hasArchivedConversations = self.viewModel.hasArchivedConversations
            self.noConversationLabel.alpha = hasArchivedConversations ? 1.0 : 0.0
            self.onboardingHint.alpha = hasArchivedConversations ? 0.0 : 1.0
        }

        if animated {
            UIView.animate(withDuration: 0.20, animations: closure)
        } else {
            closure()
        }
    }

    func hideNoContactLabel(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.20 : 0.0, animations: {
            self.noConversationLabel.alpha = 0.0
            self.onboardingHint.alpha = 0.0
        })
    }

    func updateBottomBarSeparatorVisibility(with controller: ConversationListContentController) {
        let controllerHeight = controller.view.bounds.height
        let contentHeight = controller.collectionView.contentSize.height
        let offsetY = controller.collectionView.contentOffset.y
        let showSeparator = contentHeight - offsetY + ConversationListViewController.contentControllerBottomInset > controllerHeight

        if bottomBarController.showSeparator != showSeparator {
            bottomBarController.showSeparator = showSeparator
        }
    }

    /// Scroll to the current selection
    ///
    /// - Parameter animated: perform animation or not
    @objc(scrollToCurrentSelectionAnimated:)
    func scrollToCurrentSelection(animated: Bool) {
        listContentController.scrollToCurrentSelection(animated: animated)
    }

    func createPeoplePickerController() -> StartUIViewController {
        let startUIViewController = StartUIViewController()
        startUIViewController.delegate = viewModel
        return startUIViewController
    }

    func updateArchiveButtonVisibilityIfNeeded(showArchived: Bool) {
        if showArchived == bottomBarController.showArchived {
            return
        }
        
        UIView.performWithoutAnimation {
            self.bottomBarController.showArchived = showArchived
            
            UIView.transition(with: bottomBarController.view, duration: 0.35, options: .transitionCrossDissolve, animations: {
                self.bottomBarController.view.layoutIfNeeded()
            })
        }
    }

    @objc
    func hideArchivedConversations() {
        setState(.conversationList, animated:true)
    }

    func presentPeoplePicker() {
        setState(.peoplePicker, animated: true)
    }

    func selectOnListContentController(_ conversation: ZMConversation!, scrollTo message: ZMConversationMessage?, focusOnView focus: Bool, animated: Bool, completion: (() -> Void)?) -> Bool {
        return listContentController.select(conversation,
                                     scrollTo: message,
                                     focusOnView: focus,
                                     animated: animated,
                                     completion: completion)
    }
    
    func didSelectNoDisturbedConversations() {
        let vc = ConversationListContentController()
        vc.backDelegate = self
        vc.listViewModel = ConversationListViewModel(kind: [.noDisturbConversations])
        vc.contentDelegate = viewModel
        vc.listViewModel.delegate = vc
        vc.setBackClickAndTitle()
        vc.view.backgroundColor = UIColor.dynamic(scheme: .background)
        self.presentFullscreenPossible(vc.wrapInNavigationController())
    }

    var hasUsernameTakeoverViewController: Bool {
        return usernameTakeoverViewController != nil
    }
}

extension ConversationListViewController: TopNavAutoHideAnimator {
    func showTopNav() {
        navigantionBarShouldHide(false)
    }
    
    func hideTopNav() {
        navigantionBarShouldHide(true)
    }
    
    private func navigantionBarShouldHide(_ isHidden: Bool) {
        let transform: CGAffineTransform = isHidden ? CGAffineTransform(translationX: 0, y: -(UIScreen.safeArea.top + 44 + 20)) : .identity
        let delayTime: Double = isHidden ? 0.0 : 1.0
        delay(delayTime) {
            UIView.animate(withDuration: 0.3, animations: {
                self.topNavView.transform = transform
//                UIApplication.shared.wr_setStatusBarHidden(isHidden, with: .slide)
            })
        }
    }
}

extension ConversationListViewController: ConversationListContentBackDelegate {
    func backButtonClick() {
        wr_splitViewController?.setLeftViewControllerRevealed(true, animated: true, completion: nil)
        wr_splitViewController?.setRightViewController(nil, animated: false)
    }
}

fileprivate extension NSAttributedString {
    static var attributedTextForNoConversationLabel: NSAttributedString? {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.setParagraphStyle(NSParagraphStyle.default)

        paragraphStyle.paragraphSpacing = 10
        paragraphStyle.alignment = .center

        let titleAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.smallMediumFont,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]

        paragraphStyle.paragraphSpacing = 4

        let titleString = "conversation_list.empty.all_archived.message".localized

        let attributedString = NSAttributedString(string: titleString.uppercased(), attributes: titleAttributes)

        return attributedString
    }
}
