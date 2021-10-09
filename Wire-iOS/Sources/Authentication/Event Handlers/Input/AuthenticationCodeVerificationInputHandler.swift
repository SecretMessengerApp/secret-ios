
import Foundation

/**
 * Handles the input of the 6-digit verification code.
 */

class AuthenticationCodeVerificationInputHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Any) -> [AuthenticationCoordinatorAction]? {
        // Only handle string values.
        guard let code = context as? String else {
            return nil
        }

        // Only handle input during non-team code validation
        switch currentStep {
        case .enterActivationCode, .enterLoginCode:
            return [.continueFlowWithLoginCode(code)]
        default:
            return nil
        }
    }
    
}
