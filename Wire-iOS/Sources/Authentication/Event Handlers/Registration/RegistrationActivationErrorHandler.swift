
import Foundation

/**
 * Handles errors during registration activation.
 */

class RegistrationActivationErrorHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: NSError) -> [AuthenticationCoordinatorAction]? {
        let error = context
        var postAlertAction: [AuthenticationCoordinatorAction] = [.unwindState(withInterface: false)]

        // Only handle errors during authentication requests
        switch currentStep {
        case .sendActivationCode:
            break
        case .activateCredentials:
            postAlertAction.append(.executeFeedbackAction(.clearInputFields))
        default:
            return nil
        }

        // Show the alert
        let errorAlert = AuthenticationCoordinatorErrorAlert(error: error, completionActions: postAlertAction)
        return [.hideLoadingView, .presentErrorAlert(errorAlert)]
    }

}
