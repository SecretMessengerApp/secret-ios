
import Foundation

/**
 * Valid response actions for authentication events.
 */

enum AuthenticationCoordinatorAction {
    case showLoadingView
    case hideLoadingView
    case unwindState(withInterface: Bool)
    case executeFeedbackAction(AuthenticationErrorFeedbackAction)
    case presentAlert(AuthenticationCoordinatorAlert)
    case presentErrorAlert(AuthenticationCoordinatorErrorAlert)
    case completeBackupStep
    case completeLoginFlow
    case completeRegistrationFlow
    case startPostLoginFlow
    case transition(AuthenticationFlowStep, mode: AuthenticationStateController.StateChangeMode)
    case performPhoneLoginFromRegistration(phoneNumber: String)
    case configureNotifications
    case startIncrementalUserCreation(UnregisteredUser)
    case setMarketingConsent(Bool)
    case completeUserRegistration
    case openURL(URL)
    case repeatAction
    case advanceTeamCreation(String)
    case displayInlineError(NSError)
    case assignRandomProfileImage
    case continueFlowWithLoginCode(String)
    case switchCredentialsType(AuthenticationCredentialsType)
    case startRegistrationFlow(UnverifiedCredentials)
    case startLoginFlow(AuthenticationLoginRequest)
    case setUserName(String)
    case setUserPassword(String)
    case startCompanyLogin(code: UUID?)
    case startBackupFlow
    case signOut(warn: Bool)
    case addEmailAndPassword(ZMEmailCredentials)

    var retainsModal: Bool {
        switch self {
        case .openURL:
            return true
        default:
            return false
        }
    }
}

// MARK: - Alerts

/**
 * A customizable alert to display inside the coordinator's presenter.
 */

struct AuthenticationCoordinatorAlert {
    let title: String?
    let message: String?
    let actions: [AuthenticationCoordinatorAlertAction]
}

/**
 * An action that is part of an authentication coordinator alert.
 */

struct AuthenticationCoordinatorAlertAction {
    let title: String
    let coordinatorActions: [AuthenticationCoordinatorAction]
    let style: UIAlertAction.Style

    init(title: String, coordinatorActions: [AuthenticationCoordinatorAction], style: UIAlertAction.Style = .default) {
        self.title = title
        self.coordinatorActions = coordinatorActions
        self.style = style
    }
}

extension AuthenticationCoordinatorAlertAction {
    static let ok: AuthenticationCoordinatorAlertAction = AuthenticationCoordinatorAlertAction(title: "general.ok".localized, coordinatorActions: [])
    static let cancel: AuthenticationCoordinatorAlertAction = AuthenticationCoordinatorAlertAction(title: "general.cancel".localized, coordinatorActions: [], style: .cancel)
}

/**
 * A customizable alert to display inside the coordinator's presenter.
 */

struct AuthenticationCoordinatorErrorAlert {
    let error: NSError
    let completionActions: [AuthenticationCoordinatorAction]
}

enum AuthenticationLoginRequest {
    case email(address: String, password: String)
    case phoneNumber(String)
}
