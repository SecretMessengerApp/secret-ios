
import Foundation

/**
 * Handle e-mail login errors that occur for unknown errors.
 */

class AuthenticationEmailLoginUnknownErrorHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: NSError) -> [AuthenticationCoordinatorAction]? {
        let error = context

        // Only handle e-mail login errors
        guard case let .authenticateEmailCredentials(credentials) = currentStep else {
            return nil
        }

        // Only handle unknownError error
        guard error.userSessionErrorCode == .unknownError else {
            return nil
        }

        // We try to validate the fields to detect an error
        var detectedError: NSError

        if !ZMUser.isValidEmailAddress(credentials.email) {
            detectedError = NSError(domain: NSError.ZMUserSessionErrorDomain, code: Int(ZMUserSessionErrorCode.invalidEmail.rawValue), userInfo: nil)
        } else if !ZMUser.isValidPassword(credentials.password) {
            detectedError = NSError(domain: NSError.ZMUserSessionErrorDomain, code: Int(ZMUserSessionErrorCode.invalidCredentials.rawValue), userInfo: nil)
        } else {
            detectedError = error
        }

        // Show the alert with a guidance dot

        let alert = AuthenticationCoordinatorErrorAlert(error: detectedError,
                                                        completionActions: [.unwindState(withInterface: false)])

        return [.hideLoadingView, .executeFeedbackAction(.showGuidanceDot), .presentErrorAlert(alert)]
    }

}
