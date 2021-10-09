
import Foundation

/**
 * Handles the event that informs the app when the phone login code is available.
 */

class AuthenticationLoginCodeAvailableEventHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Void) -> [AuthenticationCoordinatorAction]? {
        // Only handle the case where we are waiting for a phone number
        guard case let .sendLoginCode(phoneNumber, isResend) = currentStep else {
            return nil
        }

        var actions: [AuthenticationCoordinatorAction] = [.hideLoadingView]

        // Do not transition to a new state if the user asked the code manually
        if !isResend {
            let nextStep = AuthenticationFlowStep.enterLoginCode(phoneNumber: phoneNumber)
            actions.append(.transition(nextStep, mode: .normal))
        } else {
            actions.append(.unwindState(withInterface: false))
        }

        return actions
    }

}
