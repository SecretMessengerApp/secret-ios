
import Foundation

/**
 * Handles the success of the send activation code request.
 */

class RegistrationActivationCodeSentEventHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Void) -> [AuthenticationCoordinatorAction]? {
        // Only handle email activation success
        guard case let .sendActivationCode(credentials, user, isResend) = currentStep else {
            return nil
        }

        // Create the list of actions
        var actions: [AuthenticationCoordinatorAction] = [.hideLoadingView]

        if (!isResend) {
            let nextStep = AuthenticationFlowStep.enterActivationCode(credentials, user: user)
            actions.append(AuthenticationCoordinatorAction.transition(nextStep, mode: .normal))
        } else {
            actions.append(.unwindState(withInterface: false))
        }

        return actions
    }

}
