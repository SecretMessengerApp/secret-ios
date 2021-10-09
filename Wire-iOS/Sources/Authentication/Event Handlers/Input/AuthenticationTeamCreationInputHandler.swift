
import Foundation

/**
 * Handles user input during team creation.
 */

class AuthenticationTeamCreationInputHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Any) -> [AuthenticationCoordinatorAction]? {
        // Only handle input during team creation
        guard case .teamCreation = currentStep else {
            return nil
        }

        // Only handle text input
        guard let value = context as? String else {
            return nil
        }

        return [.advanceTeamCreation(value)]
    }

}
