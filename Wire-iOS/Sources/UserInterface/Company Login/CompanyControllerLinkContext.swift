
import Foundation

/**
 * The actions that can be executed in response to an authentication event.
 */

enum CompanyLoginLinkResponseAction: Equatable {
    /// Start the company login flow.
    case allowStartingFlow

    /// Do not start the company login flow.
    case preventStartingFlow

    /// Show an alert with a dismiss button.
    case showDismissableAlert(title: String, message: String, allowStartingFlow: Bool)
}

/**
 * The context for evaluating the actions to perform in response to an SSO link click.
 *
 * Objects that implement this protocol need to provide certain properties. These will be used
 * in the default implementations of `actionForValidLink()` and `actionForInvalidRequest()`,
 * which you can use to respond to URL scheme input.
 */

protocol CompanyLoginLinkResponseContext {
    /// The number of accounts currently logged into the app.
    var numberOfAccounts: Int { get }
}

extension CompanyLoginLinkResponseContext {

    /// The action to execute in case of a valid link.
    func actionForValidLink() -> CompanyLoginLinkResponseAction {
        if numberOfAccounts < SessionManager.maxNumberAccounts {
            return .allowStartingFlow
        } else {
            return .showDismissableAlert(
                title: "self.settings.add_account.error.title".localized,
                message: "self.settings.add_account.error.message".localized,
                allowStartingFlow: false
            )
        }
    }

    /// The action to execute in case of an invalid link.
    func actionForInvalidRequest(error: ConmpanyLoginRequestError) -> CompanyLoginLinkResponseAction {
        switch error {
        case .invalidLink:
            return .showDismissableAlert(
                title: "login.sso.start_error_title".localized,
                message: "login.sso.link_error_message".localized,
                allowStartingFlow: false
            )
        }
    }

}

// MARK: - Concrete Context

/**
 * The context for opening SSO links from the app root view controller.
 */

struct DefaultCompanyControllerLinkResponseContext: CompanyLoginLinkResponseContext {

    let sessionManager: SessionManager
    let appState: AppState
    let authenticationCoordinator: AuthenticationCoordinator?

    var numberOfAccounts: Int {
        return SessionManager.shared?.accountManager.accounts.count ?? 0
    }

    init(sessionManager: SessionManager, appState: AppState, authenticationCoordinator: AuthenticationCoordinator?) {
        self.sessionManager = sessionManager
        self.appState = appState
        self.authenticationCoordinator = authenticationCoordinator
    }

}
