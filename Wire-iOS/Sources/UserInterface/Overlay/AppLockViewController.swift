
import Foundation
import Cartography


private let zmLog = ZMSLog(tag: "UI")

extension Notification.Name {
    static let appUnlocked = Notification.Name("AppUnlocked")
}

final class AppLockViewController: UIViewController {
    fileprivate var lockView: AppLockView!
    fileprivate var localAuthenticationCancelled: Bool = false
    fileprivate var localAuthenticationNeeded: Bool = true

    fileprivate var dimContents: Bool = false {
        didSet {
            view.window?.isHidden = !dimContents
        }
    }
    
    static let shared = AppLockViewController()

    static var isLocked: Bool {
        return shared.dimContents
    }

    convenience init() {
        self.init(nibName:nil, bundle:nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AppLockViewController.applicationWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: .none)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AppLockViewController.applicationDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: .none)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AppLockViewController.applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: .none)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lockView = AppLockView()
        self.lockView.onReauthRequested = { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.localAuthenticationCancelled = false
            self.localAuthenticationNeeded = true
            self.showUnlockIfNeeded()
        }
        
        self.view.addSubview(self.lockView)
        
        constrain(self.view, self.lockView) { view, lockView in
            lockView.edges == view.edges
        }
        
        self.dimContents = false
    }
    
    fileprivate func showUnlockIfNeeded() {
        if AppLock.isActive && self.localAuthenticationNeeded {
            self.dimContents = true
        
            if self.localAuthenticationCancelled {
                self.lockView.showReauth = true
            }
            else {
                self.lockView.showReauth = false
                self.requireLocalAuthenticationIfNeeded { result in
                    
                    let granted = result == .granted
                    
                    self.dimContents = !granted
                    self.localAuthenticationCancelled = !granted
                    self.localAuthenticationNeeded = !granted
                    
                    if case .unavailable = result {
                        self.lockView.showReauth = true
                    }
                }
            }
        }
        else {
            self.lockView.showReauth = false
            self.dimContents = false
        }
    }

    /// @param callback confirmation; if the auth is not needed or is not possible on the current device called with '.none'
    func requireLocalAuthenticationIfNeeded(with callback: @escaping (AppLock.AuthenticationResult)->()) {
        guard AppLock.isActive else {
            return callback(.granted)
        }
        
        let lastAuthDate = AppLock.lastUnlockedDate
        
        // The app was authenticated at least N seconds ago
        let timeSinceAuth = -lastAuthDate.timeIntervalSinceNow
        if timeSinceAuth >= 0 && timeSinceAuth < Double(AppLock.rules.appLockTimeout) {
            callback(.granted)
            return
        }
        
        AppLock.evaluateAuthentication(description: "self.settings.privacy_security.lock_app.description".localized) { result in
            DispatchQueue.main.async {
                callback(result)
                if case .granted = result {
                    AppLock.lastUnlockedDate = Date()
                    NotificationCenter.default.post(name: .appUnlocked, object: self, userInfo: nil)
                }
            }
        }
    }
}

// MARK: - Application state observators

extension AppLockViewController {
    @objc func applicationWillResignActive() {
        if AppLock.isActive {
            self.dimContents = true
        }
    }
    
    @objc func applicationDidEnterBackground() {
        if !self.localAuthenticationNeeded {
            AppLock.lastUnlockedDate = Date()
        }

        self.localAuthenticationCancelled = false

        self.localAuthenticationNeeded = true
        if AppLock.isActive {
            self.dimContents = true
        }
    }
    
    @objc func applicationDidBecomeActive() {
        showUnlockIfNeeded()
    }
}
