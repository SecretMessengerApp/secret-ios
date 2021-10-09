
import Foundation
import SafariServices
import AuthenticationServices

protocol CompanyLoginFlowHandlerDelegate: class {
    /// Called when the user cancels the company login flow.
    func userDidCancelCompanyLoginFlow()
}

/**
 * Handles opening URLs to validate company login authentication.
 */

class CompanyLoginFlowHandler {

    /// The delegate of the flow handler.
    weak var delegate: CompanyLoginFlowHandlerDelegate?

    /// Whether we allow the in-app browser. Defaults to `true`.
    var enableInAppBrowser: Bool = true

    /// Whether we allow the system authentication session. Defaults to `false`.
    var enableAuthenticationSession: Bool = false

    private let callbackScheme: String
    private var currentAuthenticationSession: NSObject?
    private var token: Any?

    private var activeWebBrowser: UIViewController? {
        didSet {
            startListeningToFlowCompletion()
        }
    }

    deinit {
        token.apply(NotificationCenter.default.removeObserver)
    }

    // MARK: - Initialization

    /// Creates the flow handler with the given callback URL scheme.
    init(callbackScheme: String) {
        self.callbackScheme = callbackScheme
    }

    // MARK: - Flow

    /// Opens the company login flow at the specified start URL.
    func open(authenticationURL: URL) {
        guard enableInAppBrowser else {
            UIApplication.shared.open(authenticationURL)
            return
        }

        guard enableAuthenticationSession else {
            openSafariEmbed(at: authenticationURL)
            return
        }

        if #available(iOS 11, *) {
            openSafariAuthenticationSession(at: authenticationURL)
        } else {
            openSafariEmbed(at: authenticationURL)
        }
    }

    private func startListeningToFlowCompletion() {
        token = NotificationCenter.default.addObserver(forName: .companyLoginDidFinish, object: nil, queue: .main) { [weak self] _ in
            self?.activeWebBrowser?.dismiss(animated: true, completion: nil)
            self?.activeWebBrowser = nil
        }
    }

    // MARK: - Utilities

    @available(iOS 11, *)
    private func openSafariAuthenticationSession(at url: URL) {
        if #available(iOS 12, *) {
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackScheme) { url, error in
                if let url = url {
                    SessionManager.shared?.urlHandler.openURL(url, options: [:])
                }
                
                self.currentAuthenticationSession = nil
            }

            currentAuthenticationSession = session
            session.start()
        } else {
            let session = SFAuthenticationSession(url: url, callbackURLScheme: callbackScheme) { url, error in
                if let url = url {
                    SessionManager.shared?.urlHandler.openURL(url, options: [:])
                }
                
                self.currentAuthenticationSession = nil
            }

            currentAuthenticationSession = session
            session.start()
        }
    }

    private func openSafariEmbed(at url: URL) {
        let safariViewController = BrowserViewController(url: url)
        safariViewController.completion = {
            self.delegate?.userDidCancelCompanyLoginFlow()
        }

        activeWebBrowser = safariViewController
        UIApplication.shared.topmostViewController()?.present(safariViewController, animated: true, completion: nil)
    }

}
