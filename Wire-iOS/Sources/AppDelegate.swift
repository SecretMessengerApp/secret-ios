
import Foundation
import UIKit
import WireSystem
import SDWebImageWebPCoder
@_exported import WireCommonComponents
@_exported import WireSyncEngine

enum ApplicationLaunchType {
    case unknown
    case direct
    case push
    case url
    case registration
    case passwordReset
}

extension Notification.Name {
    static let ZMUserSessionDidBecomeAvailable = Notification.Name("ZMUserSessionDidBecomeAvailableNotification")
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    let zmLog = ZMSLog(tag: "AppDelegate")

    @objc
    var window: UIWindow? {
        get {
            return rootViewController?.mainWindow
        }
        
        set {
            assert(true, "cannot set window")
        }
    }
    
    // Singletons
    var unauthenticatedSession: UnauthenticatedSession? {
        return SessionManager.shared?.unauthenticatedSession
    }
    
    var callWindowRootViewController: CallWindowRootViewController? {
        return rootViewController?.callWindow.rootViewController as? CallWindowRootViewController
    }
    
    var notificationsWindow: UIWindow? {
        return rootViewController?.overlayWindow
    }
    
    @objc
    private(set) var rootViewController: AppRootViewController!
    private(set) var launchType: ApplicationLaunchType = .unknown
    var appCenterInitCompletion: Completion?
    
    var launchOptions: [AnyHashable : Any] = [:]
    
    private static var sharedAppDelegate: AppDelegate!

    static var shared: AppDelegate {
        return sharedAppDelegate!
    }

    @objc
    var mediaPlaybackManager: MediaPlaybackManager? {
        return (rootViewController.visibleViewController as? ZClientViewController)?.mediaPlaybackManager
    }

    // When running production code, this should always be true to ensure that we set the self user provider
    // on the `SelfUser` helper. The `TestingAppDelegate` subclass should override this with `false` in order
    // to require explict configuration of the self user.
    
    var shouldConfigureSelfUserProvider: Bool {
        return true
    }
    
    override init() {
        super.init()
        AppDelegate.sharedAppDelegate = self
        
        _ = Settings.shared
    }
    
    func setupBackendEnvironment() {
        AutomationHelper.sharedHelper.persistBackendTypeToGroup()
        AutomationHelper.sharedHelper.persistApplicationIdentifier()
        guard let backendTypeOverride = AutomationHelper.sharedHelper.backendEnvironmentTypeOverride() else {
            return
        }
        AutomationHelper.sharedHelper.persistBackendTypeOverrideIfNeeded(with: backendTypeOverride)
    }
    
    func showGuidePageWhenNewVersionAvailable() {
        if NewVersionChecker().isNewVersionAvailable {
            let guideView = GuideView()
            self.window?.addSubview(guideView)
            guideView.translatesAutoresizingMaskIntoConstraints = false
            guideView.pinEdgesToSuperviewEdges()
            self.window?.bringSubviewToFront(guideView)
        }
    }
    
    private func setupService() {
        let coder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(coder)
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        zmLog.info("application:willFinishLaunchingWithOptions \(String(describing: launchOptions)) (applicationState = \(application.applicationState.rawValue))")
        
        // Initial log line to indicate the client version and build
        zmLog.info("Wire-ios version \(String(describing: Bundle.main.infoDictionary?["CFBundleShortVersionString"])) (\(String(describing: Bundle.main.infoDictionary?[kCFBundleVersionKey as String])))")
        
        // Note: if we instantiate the root view controller (& windows) any earlier,
        // the windows will not receive any info about device orientation.
        rootViewController = AppRootViewController()
        showGuidePageWhenNewVersionAvailable()
        
        PerformanceDebugger.shared.start()
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        ZMSLog.switchCurrentLogToPrevious()
        
        zmLog.info("application:didFinishLaunchingWithOptions START \(String(describing: launchOptions)) (applicationState = \(application.applicationState.rawValue))")
        
        setupBackendEnvironment()
        
        setupTracking()
        NotificationCenter.default.addObserver(self, selector: #selector(userSessionDidBecomeAvailable(_:)), name: Notification.Name.ZMUserSessionDidBecomeAvailable, object: nil)
        
        setupAppCenter() {
            self.zmLog.info("Finish init app center")

            self.rootViewController?.launch(with: launchOptions ?? [:])
            self.updateAppCenterUserInfo()
        }
        
        if let launchOptions = launchOptions {
            self.launchOptions = launchOptions
        }
        
        zmLog.info("application:didFinishLaunchingWithOptions END \(String(describing: launchOptions))")
        zmLog.info("Application was launched with arguments: \(ProcessInfo.processInfo.arguments)")
        
        setupService()
        registerPush()
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        zmLog.info("applicationWillEnterForeground: (applicationState = \(application.applicationState.rawValue)")
        removeAllDeliveredNotifications()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        zmLog.info("applicationDidBecomeActive (applicationState = \(application.applicationState.rawValue))")
        AutomationHelper.sharedHelper.persistBecomeActiveStatusToGroup()
        switch launchType {
        case .url,
             .push:
            break
        default:
            launchType = .direct
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        zmLog.info("applicationWillResignActive:  (applicationState = \(application.applicationState.rawValue))")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        zmLog.info("applicationDidEnterBackground:  (applicationState = \(application.applicationState.rawValue))")
        AutomationHelper.sharedHelper.persistResignActiveStatusToGroup()
        launchType = .unknown
        
        UserDefaults.standard.synchronize()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return open(url: url, options: options)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        zmLog.info("applicationWillTerminate:  (applicationState = \(application.applicationState.rawValue))")
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        rootViewController?.quickActionsManager?.performAction(for: shortcutItem, completionHandler: completionHandler)
    }
    
    func setupTracking() {
        let containsConsoleAnalytics = ProcessInfo.processInfo.arguments.contains(AnalyticsProviderFactory.ZMConsoleAnalyticsArgumentKey)
        
        let trackingManager = TrackingManager.shared
        
        AnalyticsProviderFactory.shared.useConsoleAnalytics = containsConsoleAnalytics
        Analytics.loadShared(withOptedOut: trackingManager.disableCrashAndAnalyticsSharing)
    }
    
    func removeAllDeliveredNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    @objc
    func userSessionDidBecomeAvailable(_ notification: Notification?) {
        launchType = .direct
        if launchOptions[UIApplication.LaunchOptionsKey.url] != nil {
            launchType = .url
        }
        
        if launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] != nil {
            launchType = .push
        }
        trackErrors()
    }
    
    // MARK: - URL handling

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        zmLog.info("application:continueUserActivity:restorationHandler: \(userActivity)")
        return SessionManager.shared?.continueUserActivity(userActivity, restorationHandler: restorationHandler) ?? false
    }
    
    // MARK : - BackgroundUpdates
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        zmLog.info("application:didReceiveRemoteNotification:fetchCompletionHandler: notification: \(userInfo)")
        
        launchType = (application.applicationState == .inactive || application.applicationState == .background) ? .push : .direct
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        zmLog.info("application:performFetchWithCompletionHandler:")
        
        rootViewController?.performWhenAuthenticated() {
            ZMUserSession.shared()?.application(application, performFetchWithCompletionHandler: completionHandler)
        }
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        zmLog.info("application:handleEventsForBackgroundURLSession:completionHandler: session identifier: \(identifier)")
        
        rootViewController?.performWhenAuthenticated() {
            ZMUserSession.shared()?.application(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
        }
    }
}

extension AppDelegate {
    func registerPush() {
        guard #available(iOS 13.3, *) else {
            return
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("User comfirm push")
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenStr = deviceToken.map { String(format: "%02.2hhx", arguments: [$0]) }.joined()
        print("apns token:", deviceTokenStr)
        UserDefaults.standard.set(deviceTokenStr, forKey: ApnsPushTokenStrategy.Keys.UserClientApnsPushTokenKey)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("register apns failed:", error.localizedDescription)
    }
}
