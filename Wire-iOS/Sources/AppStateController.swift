
import Foundation
import WireSystem

private let zmLog = ZMSLog(tag: "AppState")

protocol AppStateControllerDelegate : class {
    
    func appStateController(transitionedTo appState : AppState, transitionCompleted: @escaping () -> Void)
    
    func appStateController(registerError error : Error, accountId: UUID)
    
    func hasAuthenticationCoordinator() -> Bool

}

final class AppStateController : NSObject {

    /**
     * The possible states of authentication.
     */

    enum AuthenticationState {
        /// The user is not logged in.
        case loggedOut

        /// The user logged in. This contains a flag to check if the account is new in the database.
        case loggedIn(addedAccount: Bool)

        /// The state is not determnined yet. This is the default, until we hear about the state from the session manager.
        case undetermined
    }
    
    private(set) var appState : AppState = .headless
    private(set) var lastAppState : AppState = .headless
    private var authenticationObserverToken : ZMAuthenticationStatusObserver?
    public weak var delegate : AppStateControllerDelegate? = nil
    
    fileprivate var isBlacklisted = false
    fileprivate var isJailbroken = false
    fileprivate var hasEnteredForeground = false
    fileprivate var isMigrating = false
    fileprivate var loadingAccount : Account?
    fileprivate var authenticationError : NSError?
    fileprivate var isRunningTests = ProcessInfo.processInfo.isRunningTests
    var isRunningSelfUnitTest = false

    /// The state of authentication.
    fileprivate(set) var authenticationState: AuthenticationState = .undetermined
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        appState = calculateAppState()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func calculateAppState() -> AppState {
        guard !isRunningTests || isRunningSelfUnitTest else { return .headless }

        if !hasEnteredForeground {
            return .headless
        }
        
        if isMigrating {
            return .migrating
        }
        
        if isBlacklisted {
            return .blacklisted(jailbroken: false)
        }
        
        if isJailbroken {
            return .blacklisted(jailbroken: true)
        }
        
        if let account = loadingAccount {
            return .loading(account: account, from: SessionManager.shared?.accountManager.selectedAccount)
        }

        switch authenticationState {
        case .loggedIn(let addedAccount):
            return .authenticated(completedRegistration: addedAccount)
        case .loggedOut:
            return .unauthenticated(error: authenticationError)
        case .undetermined:
            return .headless
        }
    }
    
    func updateAppState(registerError error: Error? = nil, accountId: UUID? = nil, completion: (() -> Void)? = nil) {

        let newAppState = calculateAppState()
        
        switch (appState, newAppState) {
        case (_, .unauthenticated):
            break
        case (.unauthenticated, _):
            // only clear the error when transitioning out of the unauthenticated state
            authenticationError = nil
        default: break
        }
        
        if newAppState != appState {
            zmLog.debug("transitioning to app state: \(newAppState)")
            lastAppState = appState
            appState = newAppState
            //fix start
            let hasAuthenticationCoordinator = delegate?.hasAuthenticationCoordinator()
            //fix end

            delegate?.appStateController(transitionedTo: appState) {
                // fix start
                if let err = error, let accountid = accountId, let hascoor = hasAuthenticationCoordinator, !hascoor  {
                    self.delegate?.appStateController(registerError: err, accountId: accountid)
                }
                //fix end

                completion?()
            }
        } else {
            completion?()
        }
    }

}

extension AppStateController : SessionManagerDelegate {
    
    func sessionManagerWillLogout(error: Error?, userSessionCanBeTornDown: (() -> Void)?) {
        authenticationError = error as NSError?
        authenticationState = .loggedOut

        updateAppState {
            userSessionCanBeTornDown?()
        }
    }
    
    func sessionManagerDidFailToLogin(account: Account?, error: Error) {
        let selectedAccount = SessionManager.shared?.accountManager.selectedAccount

        // We only care about the error if it concerns the selected account, or the loading account.
        if account != nil && (selectedAccount == account || loadingAccount == account) {
            authenticationError = error as NSError
        }
        // When the account is nil, we care about the error if there are some accounts in accountManager
        else if account == nil && SessionManager.shared?.accountManager.accounts.count > 0 {
            authenticationError = error as NSError
        }

        loadingAccount = nil
        authenticationState = .loggedOut
        updateAppState(registerError: error, accountId: account?.userIdentifier, completion: nil)

    }
        
    func sessionManagerDidBlacklistCurrentVersion() {
        isBlacklisted = true
        updateAppState()
    }
    
    func sessionManagerDidBlacklistJailbrokenDevice() {
        isJailbroken = true
        updateAppState()
    }
    
    func sessionManagerWillMigrateLegacyAccount() {
        isMigrating = true
        updateAppState()
    }
    
    func sessionManagerWillMigrateAccount(_ account: Account) {
        guard account == loadingAccount else { return }
        
        isMigrating = true
        updateAppState()
    }
    
    func sessionManagerWillOpenAccount(_ account: Account, userSessionCanBeTornDown: @escaping () -> Void) {
        loadingAccount = account
        updateAppState { 
            userSessionCanBeTornDown()
        }
    }
    
    func sessionManagerActivated(userSession: ZMUserSession) {        
        userSession.checkIfLoggedIn { [weak self] (loggedIn) in
            guard loggedIn else { return }
            
            // NOTE: we don't enter the unauthenticated state here if we are not logged in
            //       because we will receive `sessionManagerDidLogout()` with an auth error

            self?.authenticationState = .loggedIn(addedAccount: false)
            self?.loadingAccount = nil
            self?.isMigrating = false
            self?.updateAppState()
        }
    }
    
}

extension AppStateController {
    
    @objc func applicationDidBecomeActive() {
        hasEnteredForeground = true
        updateAppState()
    }
    
}

extension AppStateController : AuthenticationCoordinatorDelegate {

    var authenticatedUserWasRegisteredOnThisDevice: Bool {
        return ZMUserSession.shared()?.registeredOnThisDevice == true
    }

    var authenticatedUserNeedsEmailCredentials: Bool {
        return ZMUser.selfUser()?.emailAddress?.isEmpty == true
    }

    var sharedUserSession: ZMUserSession? {
        return ZMUserSession.shared()
    }

    var selfUserProfile: UserProfileUpdateStatus? {
        return sharedUserSession?.userProfile as? UserProfileUpdateStatus
    }

    var selfUser: ZMUser? {
        return ZMUser.selfUser()
    }

    var numberOfAccounts: Int {
        return SessionManager.numberOfAccounts
    }

    func userAuthenticationDidComplete(addedAccount: Bool) {
        authenticationState = .loggedIn(addedAccount: addedAccount)
        updateAppState()
    }
    
}
