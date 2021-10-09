
import Foundation

/**
 * Handles error related to e-mail login that were not caught by other handlers.
 * - warning: You need to register this handler after all e-mail error related handlers.
 */

class AuthenticationEmailFallbackErrorHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: NSError) -> [AuthenticationCoordinatorAction]? {
        let error = context

        // Only handle e-mail login errors
        guard case .authenticateEmailCredentials = currentStep else {
            return nil
        }

        // Handle the actions
        var actions: [AuthenticationCoordinatorAction] = [.hideLoadingView]

        // Show a guidance dot if the user caused the failure
        if error.userSessionErrorCode != .networkError {
            actions.append(.executeFeedbackAction(.showGuidanceDot))
        }

        let alert = AuthenticationCoordinatorErrorAlert(error: error, completionActions: [.unwindState(withInterface: false)])
        actions.append(.presentErrorAlert(alert))

        return actions
    }

}
