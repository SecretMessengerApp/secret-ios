
import Foundation

private let zmLog = ZMSLog(tag: "AuthenticationReauthenticateInputHandler")

/**
 * Handles input in the reauthentication phase.
 */

final class AuthenticationReauthenticateInputHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Any) -> [AuthenticationCoordinatorAction]? {
        // Only handle input during the reauthenticate phase.
        guard case .reauthenticate = currentStep else {
            return nil
        }

        if context is Void {
            // If we get `Void`, start the company login flow.
            return [.startCompanyLogin(code: nil)]
        } else if let (email, password) = context as? (String, String) {
            // If we get `(String, String)`, start the email flow
            let request = AuthenticationLoginRequest.email(address: email, password: password)
            return [.startLoginFlow(request)]
        } else if let fullNumber = (context as? PhoneNumber)?.fullNumber {
            // If we get `PhoneNumber`, start the phone login flow
            let request = AuthenticationLoginRequest.phoneNumber(fullNumber)
            return [.startLoginFlow(request)]
        } else {
            zmLog.error("Unable to handle context type: \(type(of: context))")
        }

        // Do not handle other cases.
        return nil
    }

}

