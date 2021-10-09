
import Foundation

/**
 * Handles errors in the final state of registration.
 */

class RegistrationFinalErrorHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: NSError) -> [AuthenticationCoordinatorAction]? {
        let error = context

        // Only handle user and team creation errors
        switch currentStep {
        case .createUser, .teamCreation(TeamCreationState.createTeam):
            break
        default:
            return nil
        }

        // Present alert
        let alert = AuthenticationCoordinatorErrorAlert(error: error, completionActions: [.unwindState(withInterface: false)])
        return [.hideLoadingView, .presentErrorAlert(alert)]
    }

}
