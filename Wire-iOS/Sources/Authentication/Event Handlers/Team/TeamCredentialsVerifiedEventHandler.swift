
import Foundation

class TeamCredentialsVerifiedEventHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Void) -> [AuthenticationCoordinatorAction]? {
        // Only handle team verification requests results
        guard case let .teamCreation(.verifyActivationCode(_, _, code)) = currentStep else {
            return nil
        }

        // Move to the next linear step
        return [.hideLoadingView, .advanceTeamCreation(code)]
    }

}
