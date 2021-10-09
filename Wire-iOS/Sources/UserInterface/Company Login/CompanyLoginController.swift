
import Foundation

protocol CompanyLoginControllerDelegate: class {

    /// The `CompanyLoginController` will never present any alerts on its own and will
    /// always ask its delegate to handle the actual presentation of the alerts.
    func controller(_ controller: CompanyLoginController, presentAlert: UIAlertController)

    /// Called when the company login controller asks the presenter to show the login spinner
    /// when performing a required task.
    func controller(_ controller: CompanyLoginController, showLoadingView: Bool)

    /// Called when the company login controller starts the company login flow.
    func controllerDidStartCompanyLoginFlow(_ controller: CompanyLoginController)

    /// Called when the company login controller cancels the company login flow.
    func controllerDidCancelCompanyLoginFlow(_ controller: CompanyLoginController)

}

///
/// `CompanyLoginController` handles the logic of deciding when to present the company login alert.
/// The controller will ask its `CompanyLoginControllerDelegate` to present alerts and never do any
/// presentation on its own.
///
/// A concrete implementation of the internally used `SharedIdentitySessionRequester` and
/// `SharedIdentitySessionRequestDetector` can be provided.
///
final class CompanyLoginController: NSObject, CompanyLoginRequesterDelegate, CompanyLoginFlowHandlerDelegate {

    weak var delegate: CompanyLoginControllerDelegate?

    var isAutoDetectionEnabled = true {
        didSet {
            isAutoDetectionEnabled ? startPollingTimer() : stopPollingTimer()
        }
    }

    // Whether the presence of a code should be checked periodically on iPad.
    // This is in order to work around https://openradar.appspot.com/28771678.
    private static let isPollingEnabled = true
    private static let fallbackURLScheme = "wire-sso"

    // Whether performing a company login is supported on the current build.
    static public let isCompanyLoginEnabled = true

    private var token: Any?
    private var pollingTimer: Timer?
    private let detector: CompanyLoginRequestDetector
    private let requester: CompanyLoginRequester
    private let flowHandler: CompanyLoginFlowHandler

    // MARK: - Initialization

    /// Create a new `CompanyLoginController` instance using the standard detector and requester.
    convenience init?(withDefaultEnvironment: ()) {
        guard CompanyLoginController.isCompanyLoginEnabled,
            let callbackScheme = Bundle.ssoURLScheme else { return nil } // Disable on public builds
        
        requireInternal(nil != Bundle.ssoURLScheme, "no valid callback scheme")

        let requester = CompanyLoginController.createRequester(with: callbackScheme)
        self.init(detector: .shared, requester: requester)
    }
    
    static private func createRequester(with scheme: String?) -> CompanyLoginRequester {
        return CompanyLoginRequester(
            callbackScheme: scheme ?? CompanyLoginController.fallbackURLScheme
        )
    }

    /// Create a new `CompanyLoginController` instance using the specified requester.
    required init(detector: CompanyLoginRequestDetector, requester: CompanyLoginRequester) {
        self.detector = detector
        self.requester = requester
        self.flowHandler = CompanyLoginFlowHandler(callbackScheme: requester.callbackScheme)
        super.init()
        setupObservers()
        flowHandler.enableInAppBrowser = true
        flowHandler.delegate = self
    }

    deinit {
        token.apply(NotificationCenter.default.removeObserver)
    }
    
    private func setupObservers() {
        requester.delegate = self

        token = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main,
            using: { [internalDetectLoginCode] _ in internalDetectLoginCode(false) }
        )
    }
    
    private func startPollingTimer() {
        guard UIDevice.current.userInterfaceIdiom == .pad, CompanyLoginController.isPollingEnabled else { return }
        pollingTimer = .scheduledTimer(withTimeInterval: 1, repeats: true) {
            [internalDetectLoginCode] _ in internalDetectLoginCode(true)
        }
    }
    
    private func stopPollingTimer() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    // MARK: - Login Prompt Presentation
    
    func detectLoginCode() {
        internalDetectLoginCode(onlyNew: false)
    }

    /// This method will be called when the app comes back to the foreground.
    /// We then check if the clipboard contains a valid SSO login code.
    /// This method will check the `isAutoDetectionEnabled` flag in order to decide if it should run.
    func internalDetectLoginCode(onlyNew: Bool) {
        guard isAutoDetectionEnabled else { return }
        detector.detectCopiedRequestCode { [isAutoDetectionEnabled, presentLoginAlert] result in
            // This might have changed in the meantime.
            guard isAutoDetectionEnabled else { return }

            guard let result = result, !onlyNew || result.isNew else { return }
            presentLoginAlert(result.code)
        }
    }

    /// Presents the SSO login alert. If the code is available in the clipboard, we pre-fill it.
    /// Call this method when you need to present the alert in response to user interaction.
    func displayLoginCodePrompt() {
        detector.detectCopiedRequestCode { [presentLoginAlert] result in
            presentLoginAlert(result?.code)
        }
    }

    /// Presents the SSO login alert with an optional prefilled code.
    private func presentLoginAlert(prefilledCode: String?) {
        let alertController = UIAlertController.companyLogin(
            prefilledCode: prefilledCode,
            validator: CompanyLoginRequestDetector.isValidRequestCode,
            completion: { [attemptLogin] code in code.apply(attemptLogin) }
        )

        delegate?.controller(self, presentAlert: alertController)
    }

    // MARK: - Login Handling

    /// Attempt to login using the requester specified in `init`
    /// - parameter code: the code used to attempt the SSO login.
    private func attemptLogin(using code: String) {
        guard let uuid = CompanyLoginRequestDetector.requestCode(in: code) else {
            return requireInternalFailure("Should never try to login with invalid code.")
        }

        attemptLoginWithCode(uuid)
    }

    /**
     * Attemts to login with a SSO login code.
     * - parameter code: The SSO team code that was extracted from the link.
     */

    func attemptLoginWithCode(_ code: UUID) {
        guard !presentOfflineAlertIfNeeded() else { return }

        delegate?.controller(self, showLoadingView: true)
        
        let host = BackendEnvironment.shared.backendURL.host!
        requester.validate(host: host, token: code) {
            self.delegate?.controller(self, showLoadingView: false)
            guard !self.handleValidationErrorIfNeeded($0) else { return }
            self.requester.requestIdentity(host: host, token: code)
        }
    }

    private func handleValidationErrorIfNeeded(_ error: ValidationError?) -> Bool {
        guard let error = error else { return false }

        switch error {
        case .invalidCode:
            delegate?.controller(self, presentAlert: .invalidCodeError())

        case .invalidStatus(let status):
            let message = "login.sso.error.alert.invalid_status.message".localized(args: String(status))
            delegate?.controller(self, presentAlert: .companyLoginError(message))

        case .unknown:
            let message = "login.sso.error.alert.unknown.message".localized
            delegate?.controller(self, presentAlert: .companyLoginError(message))
        }

        return true
    }

    /// Attempt to login using the requester specified in `init`
    /// - returns: `true` when the application is offline and an alert was presented, `false` otherwise.
    private func presentOfflineAlertIfNeeded() -> Bool {
        guard AppDelegate.isOffline else { return false }
        delegate?.controller(self, presentAlert: .noInternetError())
        return true
    }

    // MARK: - Flow

    public func companyLoginRequester(_ requester: CompanyLoginRequester, didRequestIdentityValidationAtURL url: URL) {
        delegate?.controllerDidStartCompanyLoginFlow(self)
        flowHandler.open(authenticationURL: url)
    }

    func userDidCancelCompanyLoginFlow() {
        delegate?.controllerDidCancelCompanyLoginFlow(self)
    }

}
