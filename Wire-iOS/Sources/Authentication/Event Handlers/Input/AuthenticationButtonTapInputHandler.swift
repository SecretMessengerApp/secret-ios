
import Foundation

/**
 * Handles button taps in the authentication flow.
 */

class AuthenticationButtonTapInputHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Any) -> [AuthenticationCoordinatorAction]? {
        // Only handle button taps values.
        guard context is Void else {
            return nil
        }

        // Only handle input during specified steps.
        switch currentStep {
        case .noHistory:
            return [.showLoadingView, .configureNotifications, .completeBackupStep]
        case .clientManagement(let clients, let credentials):
            let nextStep = AuthenticationFlowStep.deleteClient(clients: clients, credentials: credentials)
            return [AuthenticationCoordinatorAction.transition(nextStep, mode: .normal)]
        case .pendingEmailLinkVerification:
            return [.repeatAction]
        default:
            return nil
        }
    }

}

