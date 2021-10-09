
import Foundation

/**
 * Handles login errors that happens during the phone login flow.
 */

class AuthenticationPhoneLoginErrorHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: NSError) -> [AuthenticationCoordinatorAction]? {
        let error = context

        // Only handle errors that happen during phone login
        switch currentStep {
        case .sendLoginCode, .authenticatePhoneCredentials:
            break
        default:
            return nil
        }

        // Prepare and return the alert
        let errorAlert = AuthenticationCoordinatorErrorAlert(error: error,
                                                             completionActions: [.unwindState(withInterface: false), .executeFeedbackAction(.clearInputFields)])

        return [.hideLoadingView, .presentErrorAlert(errorAlert)]
    }

}
