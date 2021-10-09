
import Foundation

/**
 * Handles the input of the email after log in if the user doesn't have one.
 */

class AuthenticationAddEmailPasswordInputHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Any) -> [AuthenticationCoordinatorAction]? {
        // Only handle input during the add credentials phase.
        guard case .addEmailAndPassword = currentStep else {
            return nil
        }

        // Only handle email/password tuple values
        guard let (email, password) = context as? (String, String) else {
            return nil
        }

        let credentials = ZMEmailCredentials(email: email, password: password)
        return [.addEmailAndPassword(credentials)]
    }

}
