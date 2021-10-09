
import Foundation

/**
 * Handles the case where the app is opened from an SSO link.
 */

class AuthenticationStartCompanyLoginLinkEventHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: (NSError?, Int)) -> [AuthenticationCoordinatorAction]? {
        let error = context.0

        // Only handle "add account" request errors
        guard case .addAccountRequested? = error?.userSessionErrorCode else {
            return nil
        }

        // Only handle this case if there is an SSO code in the error.
        guard let code = error?.userInfo[SessionManager.companyLoginCodeKey] as? UUID else {
            return nil
        }

        if currentStep == .start {
            return [.transition(.landingScreen, mode: .reset), .startCompanyLogin(code: code)]
        } else {
            return [.startCompanyLogin(code: code)]
        }
    }

}

