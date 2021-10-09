
import Foundation

/**
 * Handles the availability of the team verification code.
 */

class TeamEmailVerificationCodeAvailableEventHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Void) -> [AuthenticationCoordinatorAction]? {
        // Only handle team related codes
        guard case let .teamCreation(teamState) = currentStep else {
            return nil
        }

        guard case let .sendEmailCode(teamName, email, isResend) = teamState else {
            return nil
        }

        // Push verification screen if needed
        var actions: [AuthenticationCoordinatorAction] = [.hideLoadingView]

        if (!isResend) {
            let nextState: TeamCreationState = .verifyEmail(teamName: teamName, email: email)
            let nextStep: AuthenticationFlowStep = .teamCreation(nextState)
            actions.append(.transition(nextStep, mode: .normal))
        } else {
            actions.append(.unwindState(withInterface: false))
        }

        return actions
    }

}
