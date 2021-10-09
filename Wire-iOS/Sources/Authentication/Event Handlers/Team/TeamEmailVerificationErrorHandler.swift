
import Foundation

/**
 * Handles error occurring during e-mail verification.
 */

class TeamEmailVerificationErrorHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: NSError) -> [AuthenticationCoordinatorAction]? {
        let error = context
        var postAlertAction: [AuthenticationCoordinatorAction] = [.unwindState(withInterface: false)]

        // Only handle errors during team creation verification requests
        switch currentStep {
        case .teamCreation(.sendEmailCode):
            break
        case .teamCreation(.verifyActivationCode):
            postAlertAction.append(.executeFeedbackAction(.clearInputFields))
        default:
            return nil
        }

        // Show the alert
        let errorAlert = AuthenticationCoordinatorErrorAlert(error: error, completionActions: postAlertAction)
        return [.hideLoadingView, .presentErrorAlert(errorAlert)]
    }

}
