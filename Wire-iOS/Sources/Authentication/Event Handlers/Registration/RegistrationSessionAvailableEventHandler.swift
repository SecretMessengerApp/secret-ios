
import Foundation

/**
 * Handles the notification informing that the user session has been created after the user registered.
 */

class RegistrationSessionAvailableEventHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Void) -> [AuthenticationCoordinatorAction]? {
        let nextStep: AuthenticationFlowStep?

        // Only handle createUser step
        switch currentStep {
        case .createUser:
            nextStep = nil
        case .teamCreation(.createTeam):
            nextStep = .teamCreation(.inviteMembers)
        default:
            return nil
        }

        // Send the post-registration fields and wait for initial sync
        return [.transition(.pendingInitialSync(next: nextStep), mode: .normal)]
    }

}
