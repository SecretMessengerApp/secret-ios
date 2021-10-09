
import Foundation

class UserEmailUpdateCodeSentEventHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Void) -> [AuthenticationCoordinatorAction]? {
        // Only handle from the register email and password state
        guard case let .registerEmailCredentials(credentials, _) = currentStep else {
            return nil
        }

        let nextStep: AuthenticationFlowStep = .pendingEmailLinkVerification(credentials)
        return [.hideLoadingView, .transition(nextStep, mode: .normal)]
    }

}
