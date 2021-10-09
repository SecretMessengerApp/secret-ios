//

import Foundation
import UIKit
import SafariServices
import Alamofire
import avs
import WireSyncEngine

var defaultFontScheme: FontScheme = FontScheme(contentSizeCategory: UIApplication.shared.preferredContentSizeCategory)

final class AppRootViewController: UIViewController {

    let mainWindow: UIWindow
    let callWindow: CallWindow
    let overlayWindow: NotificationWindow

    fileprivate(set) var sessionManager: SessionManager?
    fileprivate(set) var quickActionsManager: QuickActionsManager?
    
    fileprivate var sessionManagerCreatedSessionObserverToken: Any?
    fileprivate var sessionManagerDestroyedSessionObserverToken: Any?
    fileprivate var soundEventListeners = [UUID : SoundEventListener]()

    fileprivate(set) var visibleViewController: UIViewController?
    fileprivate let appStateController: AppStateController
    fileprivate let fileBackupExcluder: FileBackupExcluder
    fileprivate let avsLogObserver: AVSLogObserver
    fileprivate var authenticatedBlocks : [() -> Void] = []
    fileprivate let transitionQueue: DispatchQueue = DispatchQueue(label: "transitionQueue")
    fileprivate let mediaManagerLoader = MediaManagerLoader()
    var authenticationCoordinator: AuthenticationCoordinator?

    // PopoverPresenter
    weak var presentedPopover: UIPopoverPresentationController?
    weak var popoverPointToView: UIView?


    fileprivate weak var showContentDelegate: ShowContentDelegate? {
        didSet {
            if let delegate = showContentDelegate {
                performWhenShowContentDelegateIsAvailable?(delegate)
                performWhenShowContentDelegateIsAvailable = nil
            }
        }
    }

    fileprivate var performWhenShowContentDelegateIsAvailable: ((ShowContentDelegate)->())?

    func updateOverlayWindowFrame() {
        self.overlayWindow.frame = UIApplication.shared.keyWindow?.frame ?? UIScreen.main.bounds
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        mainWindow.frame.size = size

        coordinator.animate(alongsideTransition: nil, completion: { _ in
            self.updateOverlayWindowFrame()
        })
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        appStateController = AppStateController()
        fileBackupExcluder = FileBackupExcluder()
        avsLogObserver = AVSLogObserver()

        mainWindow = UIWindow(frame: UIScreen.main.bounds)
        mainWindow.accessibilityIdentifier = "ZClientMainWindow"
        
        callWindow = CallWindow(frame: UIScreen.main.bounds)
        overlayWindow = NotificationWindow(frame: UIScreen.main.bounds)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        if #available(iOS 13.0, *) {
            let userInterfaceStyle = AppTheme.current
            overrideUserInterfaceStyle = userInterfaceStyle
            mainWindow.overrideUserInterfaceStyle = userInterfaceStyle
            callWindow.overrideUserInterfaceStyle = userInterfaceStyle
            overlayWindow.overrideUserInterfaceStyle = userInterfaceStyle
        }

        AutomationHelper.sharedHelper.installDebugDataIfNeeded()

        appStateController.delegate = self
        
        // Notification window has to be on top, so must be made visible last.  Changing the window level is
        // not possible because it has to be below the status bar.
        mainWindow.rootViewController = self
        mainWindow.makeKeyAndVisible()
        callWindow.makeKeyAndVisible()
        overlayWindow.makeKeyAndVisible()
        mainWindow.makeKey()
        callWindow.isHidden = true
        overlayWindow.isHidden = true

        type(of: self).configureAppearance()
        configureMediaManager()

        if let appGroupIdentifier = Bundle.main.appGroupIdentifier {
            let sharedContainerURL = FileManager.sharedContainerDirectory(for: appGroupIdentifier)
            fileBackupExcluder.excludeLibraryFolderInSharedContainer(sharedContainerURL: sharedContainerURL)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(onContentSizeCategoryChange), name: UIContentSizeCategory.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserGrantedAudioPermissions), name: Notification.Name.UserGrantedAudioPermissions, object: nil)

        transition(to: .headless)

        enqueueTransition(to: appStateController.appState)
        
        configAppearance()
    }
    
    func configAppearance() {
       
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .dynamic(scheme: .alertButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = mainWindow.bounds
    }

    func launch(with launchOptions: LaunchOptions) {
        let bundle = Bundle.main
        let appVersion = bundle.infoDictionary?[kCFBundleVersionKey as String] as? String
        let mediaManager = AVSMediaManager.sharedInstance()
        let analytics = Analytics.shared()
        let url = Bundle.main.url(forResource: "session_manager", withExtension: "json")!
        let configuration = SessionManagerConfiguration.load(from: url)!
        let jailbreakDetector = JailbreakDetector()
        configuration.blacklistDownloadInterval = Settings.shared.blacklistDownloadInterval

        SessionManager.clearPreviousBackups()

        SessionManager.create(
            appVersion: appVersion!,
            mediaManager: mediaManager!,
            analytics: analytics,
            delegate: appStateController,
            application: UIApplication.shared,
            environment: BackendEnvironment.shared,
            configuration: configuration,
            detector: jailbreakDetector) { sessionManager in
            self.sessionManager = sessionManager
            self.sessionManagerCreatedSessionObserverToken = sessionManager.addSessionManagerCreatedSessionObserver(self)
            self.sessionManagerDestroyedSessionObserverToken = sessionManager.addSessionManagerDestroyedSessionObserver(self)
            self.sessionManager?.foregroundNotificationResponder = self
            self.sessionManager?.showContentDelegate = self
            self.sessionManager?.switchingDelegate = self
            sessionManager.updateCallNotificationStyleFromSettings()
            sessionManager.useConstantBitRateAudio = Settings.shared[.callingConstantBitRate] ?? false
            sessionManager.start(launchOptions: launchOptions)
                
            self.quickActionsManager = QuickActionsManager(sessionManager: sessionManager,
                                                           application: UIApplication.shared)
                
            sessionManager.urlHandler.delegate = self
            if let url = launchOptions[UIApplication.LaunchOptionsKey.url] as? URL {
                sessionManager.urlHandler.openURL(url, options: [:])
            }
        }
    }

    func enqueueTransition(to appState: AppState, completion: (() -> Void)? = nil) {

        transitionQueue.async {

            let transitionGroup = DispatchGroup()
            transitionGroup.enter()

            DispatchQueue.main.async {
                self.applicationWillTransition(to: appState)
                transitionGroup.leave()
            }

            transitionGroup.wait()
        }

        transitionQueue.async {

            let transitionGroup = DispatchGroup()
            transitionGroup.enter()

            DispatchQueue.main.async {
                self.transition(to: appState, completionHandler: {
                    transitionGroup.leave()
                    self.applicationDidTransition(to: appState)
                    completion?()
                })
            }

            transitionGroup.wait()
        }
    }

    func transition(to appState: AppState, completionHandler: (() -> Void)? = nil) {
        var viewController: UIViewController? = nil
        showContentDelegate = nil

        resetAuthenticationCoordinatorIfNeeded(for: appState)

        switch appState {
        case .blacklisted(jailbroken: let jailbroken):
            viewController = BlockerViewController(context: jailbroken ? .jailbroken : .blacklist)
        case .migrating:
            let launchImageViewController = LaunchImageViewController()
            launchImageViewController.showLoadingScreen()
            viewController = launchImageViewController
        case .unauthenticated(error: let error):
            mainWindow.tintColor = .black
            AccessoryTextField.appearance(whenContainedInInstancesOf: [AuthenticationStepController.self]).tintColor = UIColor.Team.activeButton
            
            // Only execute handle events if there is no current flow
            guard authenticationCoordinator == nil ||
                  error?.userSessionErrorCode == .addAccountRequested ||
                  error?.userSessionErrorCode == .accountDeleted else {
                break
            }
            
            let navigationController = UINavigationController(navigationBarClass: AuthenticationNavigationBar.self, toolbarClass: nil)
            
            authenticationCoordinator = AuthenticationCoordinator(presenter: navigationController,
                                                                  sessionManager: SessionManager.shared!,
                                                                  featureProvider: BuildSettingAuthenticationFeatureProvider())
            
            authenticationCoordinator!.delegate = appStateController
            authenticationCoordinator!.startAuthentication(with: error, numberOfAccounts: SessionManager.numberOfAccounts)
            
            viewController = navigationController

        case .authenticated(completedRegistration: let completedRegistration):
            UIColor.setAccentOverride(.undefined)
            mainWindow.tintColor = UIColor.accent()
            executeAuthenticatedBlocks()
        
            if let selectedAccount = SessionManager.shared?.accountManager.selectedAccount {
                let clientViewController = ZClientViewController(account: selectedAccount, selfUser: ZMUser.selfUser())
                clientViewController.isComingFromRegistration = completedRegistration

                /// show the dialog only when lastAppState is .unauthenticated, i.e. the user login to a new device
                clientViewController.needToShowDataUsagePermissionDialog = false
                if case .unauthenticated(_) = appStateController.lastAppState {
                    clientViewController.needToShowDataUsagePermissionDialog = true
                }
                
                ExpressionService.getExpressions()
                
                viewController = clientViewController
            }
        case .headless:
            viewController = LaunchImageViewController()
        case .loading(account: let toAccount, from: let fromAccount):
            viewController = SkeletonViewController(from: fromAccount, to: toAccount)
        }

        if let viewController = viewController {
            transition(to: viewController, animated: true) {
                self.showContentDelegate = viewController as? ShowContentDelegate
                completionHandler?()
            }
        } else {
            completionHandler?()
        }
    }

    private func resetAuthenticationCoordinatorIfNeeded(for state: AppState) {
        switch state {
        case .unauthenticated:
            break // do not reset the authentication coordinator for unauthenticated state
        default:
            authenticationCoordinator = nil // reset the authentication coordinator when we no longer need it
        }
    }

    private func dismissModalsFromAllChildren(of viewController: UIViewController?) {
        guard let viewController = viewController else { return }
        for child in viewController.children {
            if child.presentedViewController != nil {
                child.dismiss(animated: false, completion: nil)
            }
            dismissModalsFromAllChildren(of: child)
        }
    }

    func transition(to viewController: UIViewController, animated: Bool = true, completionHandler: (() -> Void)? = nil) {

        // If we have some modal view controllers presented in any of the (grand)children
        // of this controller they stay in memory and leak on iOS 10.
        dismissModalsFromAllChildren(of: visibleViewController)
        visibleViewController?.willMove(toParent: nil)

        if let previousViewController = visibleViewController, animated {

            addChild(viewController)
            transition(from: previousViewController,
                       to: viewController,
                       duration: 0.5,
                       options: .transitionCrossDissolve,
                       animations: nil,
                       completion: { (finished) in
                    viewController.didMove(toParent: self)
                    previousViewController.removeFromParent()
                    self.visibleViewController = viewController
                    UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(true)
                    completionHandler?()
            })
        } else {
            UIView.performWithoutAnimation {
                visibleViewController?.removeFromParent()
                addChild(viewController)
                viewController.view.frame = view.bounds
                viewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                view.addSubview(viewController.view)
                viewController.didMove(toParent: self)
                visibleViewController = viewController
                UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(false)
            }
            completionHandler?()
        }
    }

    func applicationWillTransition(to appState: AppState) {

//        if appState == .authenticated(completedRegistration: false) {
//            callWindow.callController.transitionToLoggedInSession()
//        } else {
//            overlayWindow.rootViewController = NotificationWindowRootViewController()
//        }
      
        switch appState {
        case .authenticated:
            if AppDelegate.shared.shouldConfigureSelfUserProvider {
                SelfUser.provider = ZMUserSession.shared()
            }
            callWindow.callController.transitionToLoggedInSession()
        default:
            break
        }


        let colorScheme = ColorScheme.default
        colorScheme.accentColor = .accent()
        colorScheme.variant = Settings.shared.colorSchemeVariant
    }
    
    func applicationDidTransition(to appState: AppState) {
        if case .authenticated = appState {
            callWindow.callController.presentCallCurrentlyInProgress()
        } else if AppDelegate.shared.shouldConfigureSelfUserProvider {
            SelfUser.provider = nil
        }
        
        if case .unauthenticated(let error) = appState, error?.userSessionErrorCode == .accountDeleted,
           let reason = error?.userInfo[ZMAccountDeletedReasonKey] as? ZMAccountDeletedReason {
            presentAlertForDeletedAccount(reason)
        }
    }
    
    func configureMediaManager() {
        self.mediaManagerLoader.send(message: .appStart)
    }

    @objc func onContentSizeCategoryChange() {
        NSAttributedString.invalidateParagraphStyle()
        NSAttributedString.invalidateMarkdownStyle()
        ConversationListCell.invalidateCachedCellSize()
        defaultFontScheme = FontScheme(contentSizeCategory: UIApplication.shared.preferredContentSizeCategory)
        type(of: self).configureAppearance()
    }

    func performWhenAuthenticated(_ block : @escaping () -> Void) {
        if appStateController.appState == .authenticated(completedRegistration: false) {
            block()
        } else {
            authenticatedBlocks.append(block)
        }
    }

    func executeAuthenticatedBlocks() {
        while !authenticatedBlocks.isEmpty {
            authenticatedBlocks.removeFirst()()
        }
    }

    func reload() {
        enqueueTransition(to: .headless)
        enqueueTransition(to: self.appStateController.appState)
    }
    
    func AddNewAccountAction(email: String, successAdd:() -> Void) {
        if sessionManager?.accountManager.selectedAccount?.loginCredentials?.emailAddress == email {
            return
        }
        if let existAccount = sessionManager?.accountManager.accounts.filter({ (account) -> Bool in
            return account.loginCredentials?.emailAddress == email
        }), existAccount.count > 0 {
            delay(1) {
                self.sessionManager?.select(existAccount.first!)
            }
            return
        }
        if  sessionManager?.accountManager.accounts.count < SessionManager.maxNumberAccounts {
            sessionManager?.addAccount()
            successAdd()
        } else {
            if let controller = UIApplication.shared.topmostViewController(onlyFullScreen: false) {
                let alert = UIAlertController(
                    title: "self.settings.add_account.error.title".localized,
                    message: "self.settings.add_account.error.message".localized,
                    alertAction: .cancel()
                )
                controller.present(alert, animated: true, completion: nil)
            }
        }
    }

}

// MARK: - Status Bar / Supported Orientations

extension AppRootViewController {

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return wr_supportedInterfaceOrientations
    }

    override var prefersStatusBarHidden: Bool {
        return visibleViewController?.prefersStatusBarHidden ?? false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            switch traitCollection.userInterfaceStyle {
            case .unspecified: return .default
            case .light: return .darkContent
            case .dark: return .lightContent
            }
        } else {
            return .default
        }
    }
}

extension AppRootViewController {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        userInterfaceStyleDidChange(previousTraitCollection) { _ in
            UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(true)
        }
    }
}

extension AppRootViewController: AppStateControllerDelegate {

    func appStateController(transitionedTo appState: AppState, transitionCompleted: @escaping () -> Void) {
        enqueueTransition(to: appState, completion: transitionCompleted)
    }
    
    func appStateController(registerError error: Error, accountId: UUID) {
        guard let session = ZMUserSession.shared() else {return}
        authenticationCoordinator?.addInitialSyncCompletionObserver(usersessoin: session)
        authenticationCoordinator?.clientRegistrationDidFail(error as NSError, accountId: accountId)
    }
    
    func hasAuthenticationCoordinator() -> Bool {
        return !(authenticationCoordinator == nil)
    }

}

// MARK: - ShowContentDelegate

extension AppRootViewController: ShowContentDelegate {
    
    func showUserProfile(user: UserType) {
        whenShowContentDelegateIsAvailable { delegate in
            delegate.showUserProfile(user: user)
        }
    }
    
    func showConnectionRequest(userId: UUID) {
        whenShowContentDelegateIsAvailable { delegate in
            delegate.showConnectionRequest(userId: userId)
        }
    }
    

    func showConversation(_ conversation: ZMConversation, at message: ZMConversationMessage?) {
        whenShowContentDelegateIsAvailable { delegate in
            delegate.showConversation(conversation, at: message)
        }
    }
    
    func showConversationList() {
        whenShowContentDelegateIsAvailable { delegate in
            delegate.showConversationList()
        }
    }
    
    internal func whenShowContentDelegateIsAvailable(do closure: @escaping (ShowContentDelegate) -> ()) {
        if let delegate = showContentDelegate {
            closure(delegate)
        }
        else {
            self.performWhenShowContentDelegateIsAvailable = closure
        }
    }
}

// MARK: - Foreground Notification Responder

extension AppRootViewController: ForegroundNotificationResponder {
    func shouldPresentNotification(with userInfo: NotificationUserInfo) -> Bool {
        // user wants to see fg notifications
        guard false == Settings.shared[.chatHeadsDisabled] else {
            return false
        }
        
        // the concerned account is active
        guard
            let selfUserID = userInfo.selfUserID,
            selfUserID == sessionManager?.accountManager.selectedAccount?.userIdentifier
            else { return true }
        
        guard let clientVC = ZClientViewController.shared else {
            return true
        }

        if clientVC.isConversationListVisible {
            return false
        }
        
        guard clientVC.isConversationViewVisible else {
            return true
        }
        
        // conversation view is visible for another conversation
        guard
            let convID = userInfo.conversationID,
            convID != clientVC.currentConversation?.remoteIdentifier
            else { return false }
        
        return true
    }
}

// MARK: - Application Icon Badge Number

extension AppRootViewController {

    @objc fileprivate func applicationWillEnterForeground() {
        updateOverlayWindowFrame()
    }

    @objc fileprivate func applicationDidEnterBackground() {
        let unreadConversations = sessionManager?.accountManager.totalUnreadCount ?? 0
        UIApplication.shared.applicationIconBadgeNumber = unreadConversations
    }

    @objc fileprivate func applicationDidBecomeActive() {
        updateOverlayWindowFrame()
    }
}

// MARK: - Session Manager Observer

extension AppRootViewController: SessionManagerCreatedSessionObserver, SessionManagerDestroyedSessionObserver {
    
    func sessionManagerCreated(unauthenticatedSession: UnauthenticatedSession) {
        
    }

    func sessionManagerCreated(userSession: ZMUserSession) {
        
        for (accountId, session) in sessionManager?.backgroundUserSessions ?? [:] {
            if session == userSession {
                soundEventListeners[accountId] = SoundEventListener(userSession: userSession)
            }
        }
        userSession.accessTokenHandlerDelegate = self
    }

    func sessionManagerDestroyedUserSession(for accountId: UUID) {
        soundEventListeners[accountId] = nil
    }
}

// MARK: - Account Deleted Alert

extension AppRootViewController {
    
    fileprivate func presentAlertForDeletedAccount(_ reason: ZMAccountDeletedReason) {
        switch reason {
        case .sessionExpired:
            presentAlertWithOKButton(title: "account_deleted_session_expired_alert.title".localized, message: "account_deleted_session_expired_alert.message".localized)
        default:
            break
            
        }
    }
    
}

// MARK: - Audio Permissions granted

extension AppRootViewController {

    @objc func onUserGrantedAudioPermissions() {
        sessionManager?.updateCallNotificationStyleFromSettings()
    }
}

extension AppRootViewController: ZMAccessTokenHandlerDelegate {
    
    func handlerDidClearAccessToken(_ handler: ZMAccessTokenHandler!) {
        // pass
    }
    
    
    func handlerDidReceiveAccessToken(_ handler: ZMAccessTokenHandler!) {
        AuthKeyHandler.shared.createAuthKeyIfNeed()
    }
    
}

// MARK: - Ask user if they want want switch account if there's an ongoing call

extension AppRootViewController: SessionManagerSwitchingDelegate {
    
    func confirmSwitchingAccount(completion: @escaping (Bool) -> Void) {
        guard let session = ZMUserSession.shared(), session.isCallOngoing else { return completion(true) }
        guard let topmostController = UIApplication.shared.topmostViewController() else { return completion(false) }
        
        let alert = UIAlertController(title: "call.alert.ongoing.alert_title".localized,
                                      message: "self.settings.switch_account.message".localized,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "self.settings.switch_account.action".localized,
                                      style: .default,
                                      handler: { [weak self] (action) in
            if session.isCallOngoing {
                self?.sessionManager?.activeUserSession?.callCenter?.endAllCalls()
            }
            completion(true)
        }))
        alert.addAction(.cancel { completion(false) })

        topmostController.present(alert, animated: true, completion: nil)
    }
    
}

extension AppRootViewController: PopoverPresenter { }

extension SessionManager {

    func firstAuthenticatedAccount(excludingCredentials credentials: LoginCredentials?) -> Account? {
        if let selectedAccount = accountManager.selectedAccount {
            if BackendEnvironment.shared.isAuthenticated(selectedAccount) && selectedAccount.loginCredentials != credentials {
                return selectedAccount
            }
        }

        for account in accountManager.accounts {
            if BackendEnvironment.shared.isAuthenticated(account) && account != accountManager.selectedAccount && account.loginCredentials != credentials {
                return account
            }
        }

        return nil
    }

    var firstAuthenticatedAccount: Account? {
        return firstAuthenticatedAccount(excludingCredentials: nil)
    }

    static var numberOfAccounts: Int {
        return SessionManager.shared?.accountManager.accounts.count ?? 0
    }

}

extension AppRootViewController: SessionManagerURLHandlerDelegate {
    func sessionManagerShouldExecuteURLAction(_ action: URLAction, callback: @escaping (Bool) -> Void) {
        switch action {
        case .connectBot:
            guard let _ = ZMUser.selfUser().team else {
                callback(false)
                return
            }
            
            let alert = UIAlertController(title: "url_action.title".localized,
                                          message: "url_action.connect_to_bot.message".localized,
                                          preferredStyle: .alert)
            
            let agreeAction = UIAlertAction(title: "url_action.confirm".localized,
                                            style: .default) { _ in
                                                callback(true)
            }
            
            alert.addAction(agreeAction)
            
            let cancelAction = UIAlertAction(title: "general.cancel".localized,
                                             style: .cancel) { _ in
                                                callback(false)
            }
            
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)

        case .companyLoginFailure(let error):
            defer {
                authenticationCoordinator?.cancelCompanyLogin()
                notifyCompanyLoginCompletion()
            }
            
            guard case .unauthenticated = appStateController.appState else {
                callback(false)
                return
            }

            let message = "login.sso.error.alert.message".localized(args: error.displayCode)

            let alert = UIAlertController(title: "general.failure".localized,
                                          message: message,
                                          preferredStyle: .alert)

            alert.addAction(.ok(handler: { _ in
                callback(false)
            }))

            let presentAlert = {
                self.present(alert, animated: true)
            }

            if let topmostViewController = UIApplication.shared.topmostViewController() as? SFSafariViewController {
                topmostViewController.dismiss(animated: true, completion: presentAlert)
            } else {
                presentAlert()
            }

        case .companyLoginSuccess:
            defer {
                notifyCompanyLoginCompletion()
            }

            guard case .unauthenticated = appStateController.appState else {
                callback(false)
                return
            }

            callback(true)
        case .groupInvite(let userIndetifier):
            GroupManageService.join(id: userIndetifier) {result in
                switch result {
                case .success:
                    HUD.success("Joined the group")
                case .failure(let msg):
                    HUD.error(msg)
                }
            }
            callback(false)
        case .authLogin(let appid, let key):
            let vc = AuthLoginViewController(appid: appid, key: key)
            self.present(vc, animated: true, completion: nil)
            callback(false)
        case .thirdLogin(let fromid,let email, let userid):
            delay(1) {
                self.AddNewAccountAction(email: email, successAdd: {
                    DispatchQueue.once(token: NSDate().timeIntervalSince1970) {
                        self.thirdLogin(fromid: fromid, email: email, userid: userid)
                    }
                })
            }
        case .thirdLoginError(let error):
            if case .invalidUrl = error {
                HUD.error("Invalid authorization link")
            }
            callback(false)
            
        case .h5Login(let code, let url):
            let controller = H5AuthViewController(code: code, url: url)
            present(controller, animated: true, completion: nil)
            callback(false)
        case .h5LoginError(let error):
            if case .invalidUrl = error {
                HUD.error("Invalid authorization link")
            }
            callback(false)
            
        case .groupInviteError(let error):
            if case .invalidUrl = error {
                HUD.error("Invalid invitation link")
            }
            callback(false)
        case .authLoginError(let error):
            if case .invalidUrl = error {
                HUD.error("Invalid authorization link")
            }
            callback(false)
            
        case .homeScreen(_, let conversation):
            guard let conversation = conversation else { HUD.error("You are not in this group"); return }
            MainTabBarController.shared?.select(.conversationList)
            ZClientViewController.shared?.select(conversation: conversation, focusOnView: true, animated: true)
            
        default:
            break
        }
    }
    
    func dealwithPayResult(for req: PayRequest, result: Swift.Result<String, Error>) {
        let url: URL?
        switch result {
        case .success(let orderNO):
            let info: [String : Any?] = ["order_no": orderNO, "status": 0, "remark": req.remark]
            url = makeCallbackURL(appid: req.app_id, info: info.compactMapValues { $0 })
        case .failure(let error):
            var status: Int = -1
            if let err = error as? NetworkError {
                status = err.code
                HUD.error(err)
            } else if let err = error as? PayRequestError {
                status = err.rawValue
            }
            
            let info: [String : Any?] = ["status": status, "remark": req.remark]
            url = makeCallbackURL(appid: req.app_id, info: info.compactMapValues { $0 })
        }

        if let url = url {
            print("Pay callback: \(url)")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func thirdLogin(fromid: String, email: String, userid: String) {
        AuthLoginService.appThirdLoginAuth(fromid: fromid, email: email, userid: userid, label: CookieLabel.current.value) { (result) in
            switch result {
            case .loginSuccess(let json, let headers, let httpresponse, let sourceurl):
                guard let coordinator = self.authenticationCoordinator else {return}
                if  let _ = headers?["Set-Cookie"] as? String, let hresponse = httpresponse {
                    self.sessionManager?.activeUserSession?.transportSession.cookieStorage.setCookieDataFrom(hresponse, for: URL(string: sourceurl)!)
                }
              
                if json["code"].stringValue == "1002" {
                 
                    let vc = ThridLoginBindSettingViewController(coordinator:coordinator, fromid: fromid, email: email, userid: userid, label: CookieLabel.current.value)
                    self.present(vc, animated: true, completion: nil)
                    return
                }
               
                if let password = headers?["password"] as? String, let cookie = headers?["Set-Cookie"] as? String {
                    let user = json["user"].stringValue
                    let token = json["access_token"].stringValue
                    guard let useruuid = UUID(uuidString: user) else {return}
                    guard let cookiedata = HTTPCookie.extractCookieData(from: cookie, url: URL(string: "isecret.im")!) else {return}
                 
                    let uinfo = UserInfo(identifier: useruuid, cookieData: cookiedata)
                    let vc = ThridLoginPasswordSettingViewController(coordinator: coordinator, email: email, fromid: fromid, userid: userid, label: CookieLabel.current.value,oldPassword: password, userinfo:uinfo, token: token)
                    self.present(vc, animated: true, completion: nil)
                    return
                }
        
                if  !json["access_token"].stringValue.isEmpty && !json["user"].stringValue.isEmpty  {
                    guard let cookie = headers?["Set-Cookie"] as? String else {return}
                    let cookieData = HTTPCookie.extractCookieData(from: cookie, url: URL(string: "isecret.im")!)
                    guard let cookiedata = cookieData else {return}
                    guard let useruuid = UUID(uuidString: json["user"].stringValue) else {return}
                    let credential = ZMEmailCredentials.init(email: email, password: "")
                    let uinfo = UserInfo(identifier: useruuid, cookieData: cookiedata)
                    self.authenticationCoordinator?.stateController.transition(to: .authenticateEmailCredentials(credential)); self.sessionManager?.unauthenticatedSession?.authenticationStatus.loginSucceeded(with: uinfo)
                    
                }
            case .loginFailure(let error):
                HUD.error(error)
            }
        }
    }

    private func showBackendSwitchError(_ error: SessionManager.SwitchBackendError) {
        let alert: UIAlertController
        switch error {
        case .loggedInAccounts:
            alert = UIAlertController(title: "url_action.switch_backend.error.logged_in.title".localized,
                                          message: "url_action.switch_backend.error.logged_in".localized,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "general.ok".localized, style: .default, handler: nil))
        case .invalidBackend:
            alert = UIAlertController(title: "url_action.switch_backend.error.invalid_backend.title".localized,
                                          message: "url_action.switch_backend.error.invalid_backend".localized,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "general.ok".localized, style: .default, handler: nil))
        }
        self.present(alert, animated: true, completion: nil)
    }

    private func executeCompanyLoginLinkAction(_ action: CompanyLoginLinkResponseAction, callback: @escaping (Bool) -> Void) {
        switch action {
        case .allowStartingFlow:
            callback(true)

        case .preventStartingFlow:
            callback(false)

        case .showDismissableAlert(let title, let message, let allowStartingFlow):
            if let controller = UIApplication.shared.topmostViewController(onlyFullScreen: false) {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert )
                let okAction = UIAlertAction(title: "general.ok".localized, style: .cancel) { _ in callback(allowStartingFlow) }
                alert.addAction(okAction)
                controller.present(alert, animated: true)
            } else {
                callback(allowStartingFlow)
            }
        }
    }
    
    private func notifyCompanyLoginCompletion() {
        NotificationCenter.default.post(name: .companyLoginDidFinish, object: self)
    }
    
    fileprivate func waitToken(callback: @escaping ((Bool) -> Void)) {
        func checkLogin() -> Bool {
            if let transportsession = ZMUserSession.shared()?.transportSession as? ZMTransportSession, let token = transportsession.accessToken?.token, !token.isEmpty {
                return true
            } else {
                return false
            }
        }
        
        if checkLogin() {
            callback(true)
        } else {
            let startTime = Date()
            let timeout: TimeInterval = 8.0
            let interval = 0.5
            
            Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
                if checkLogin() {
                    timer.invalidate()
                    callback(true)
                } else {
                    let duration = Date().timeIntervalSince(startTime)
                    if Date().timeIntervalSince(startTime) >= timeout || duration < 0 {
                        timer.invalidate()
                        callback(false)
                    }
                }
            }
        }
    }
}

extension Notification.Name {
    static let companyLoginDidFinish = Notification.Name("Wire.CompanyLoginDidFinish")
}

extension DispatchQueue {
    
    private static var _onceTracker: TimeInterval = 0

    class func once(token: TimeInterval, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if token - _onceTracker < 2 {
            return
        }
        
        _onceTracker = token
        block()
    }
}

private func makeCallbackURL(appid: String, info: [String: Any] = [:]) -> URL? {
    let url = "secret\(appid)://callback"
    guard var components = URLComponents(string: url) else { return nil }
    
    let items = info.map { (key, value) in
        return URLQueryItem(name: key, value: "\(value)")
    }
    
    let defaultItems = [
        URLQueryItem(name: "app_id", value: "\(appid)"),
        URLQueryItem(name: "appid", value: "\(appid)"), 
    ]
    components.queryItems = defaultItems + items
    
    return components.url
}

extension UIApplication {
    @available(iOS 12.0, *)
    static var userInterfaceStyle: UIUserInterfaceStyle? {
            UIApplication.shared.keyWindow?.rootViewController?.traitCollection.userInterfaceStyle
    }
}
