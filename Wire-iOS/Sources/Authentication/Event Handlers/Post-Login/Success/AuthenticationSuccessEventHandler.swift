
import Foundation

/**
 * Handles the notification informing that the client has been registered after the client signed in.
 */

class AuthenticationClientRegistrationSuccessHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Void) -> [AuthenticationCoordinatorAction]? {
        if ZMUserSession.shared()?.hasCompletedInitialSync == true {
            return [.hideLoadingView, .completeLoginFlow]
        } else {
            return [.transition(.pendingInitialSync(next: nil), mode: .normal), .hideLoadingView]
        }
    }

}
