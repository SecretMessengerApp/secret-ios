
import Foundation

/**
 * Handles the input of the phone number or email to log in.
 */

class AuthenticationLoginCredentialsInputHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Any) -> [AuthenticationCoordinatorAction]? {
        // Only handle input during the credentials providing phase.
        guard case .provideCredentials = currentStep else {
            return nil
        }

        if let (email, password) = context as? (String, String) {
            let request = AuthenticationLoginRequest.email(address: email, password: password)
            return [.startLoginFlow(request)]
        } else if let phoneNumber = context as? PhoneNumber {
            let request = AuthenticationLoginRequest.phoneNumber(phoneNumber.fullNumber)
            return [.startLoginFlow(request)]
        } else {
            return nil
        }
    }

}
