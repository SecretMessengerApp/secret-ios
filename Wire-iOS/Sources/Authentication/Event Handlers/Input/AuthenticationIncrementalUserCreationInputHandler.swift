
import Foundation

/**
 * Handles input during the incremental user creation.
 */

class AuthenticationIncrementalUserCreationInputHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Any) -> [AuthenticationCoordinatorAction]? {
        // Only handle input during the incremental user creation.
        guard case .incrementalUserCreation(_, let step) = currentStep else {
            return nil
        }

        // Only handle string values
        guard let input = context as? String else {
            return nil
        }

        // Only handle input during name and password steps
        switch step {
        case .setName:
            return [.setUserName(input)]
        case .setPassword:
            return [.setUserPassword(input)]
        default:
            return nil
        }
    }

}
