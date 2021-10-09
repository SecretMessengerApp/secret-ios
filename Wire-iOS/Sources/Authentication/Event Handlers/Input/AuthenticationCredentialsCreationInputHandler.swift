
import Foundation

/**
 * Handles the input of the phone number or email to register.
 */

class AuthenticationCredentialsCreationInputHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Any) -> [AuthenticationCoordinatorAction]? {
        // Only handle input during the credentials creation.
        guard case .createCredentials = currentStep else {
            return nil
        }

        // Only handle known values.
        if let email = context as? String {
            return [.startRegistrationFlow(.email(email))]
        } else if let phoneNumber = context as? PhoneNumber {
            return [.startRegistrationFlow(.phone(phoneNumber.fullNumber))]
        } else {
            return nil
        }
    }

}
