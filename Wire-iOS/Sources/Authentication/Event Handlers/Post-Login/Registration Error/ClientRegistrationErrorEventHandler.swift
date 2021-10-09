
import Foundation

/**
 * A fallback error handler for registration errors.
 */

class ClientRegistrationErrorEventHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: (NSError, UUID)) -> [AuthenticationCoordinatorAction]? {
        let (error, _) = context

        // Only handle needsToRegisterEmailToRegisterClient errors
        if error.userSessionErrorCode == .needsToRegisterEmailToRegisterClient {
            // If we are already registering the credentials, do not handle the error
            switch currentStep {
            case .addEmailAndPassword, .registerEmailCredentials, .pendingEmailLinkVerification:
                return nil
            default:
                break
            }
        }

        let alert = AuthenticationCoordinatorErrorAlert(error: error, completionActions: [.unwindState(withInterface: false)])
        return [.hideLoadingView, .presentErrorAlert(alert)]
    }

}
