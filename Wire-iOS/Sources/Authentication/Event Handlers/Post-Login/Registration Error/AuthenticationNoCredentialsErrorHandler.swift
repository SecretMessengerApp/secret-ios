
import Foundation

/**
 * Handles client registration errors related to the lack of e-mail and password credentials.
 */

class AuthenticationNoCredentialsErrorHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: (NSError, UUID)) -> [AuthenticationCoordinatorAction]? {
        let (error, _) = context

        // Only handle needsToRegisterEmailToRegisterClient errors
        guard error.userSessionErrorCode == .needsToRegisterEmailToRegisterClient else {
            return nil
        }

        // If we are already registering the credentials, do not handle the error
        switch currentStep {
        case .addEmailAndPassword, .registerEmailCredentials, .pendingEmailLinkVerification:
            return nil
        default:
            break
        }

        // Verify the state and ask the user to add a password
        guard statusProvider?.selfUser != nil && statusProvider?.selfUserProfile != nil else {
            return nil
        }

        return [.hideLoadingView, .startPostLoginFlow, .transition(.addEmailAndPassword, mode: .reset)]
    }

}
