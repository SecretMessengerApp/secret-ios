
import Foundation

/**
 * Handles the success of credentials verification.
 */

class RegistrationCredentialsVerifiedEventHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Void) -> [AuthenticationCoordinatorAction]? {
        // Only handle verification requests results
        guard case let .activateCredentials(_, user, code) = currentStep else {
            return nil
        }

        // Update the user
        user.verificationCode = code

        // Move to the next linear step
        return [.hideLoadingView, .startIncrementalUserCreation(user)]
    }

}
