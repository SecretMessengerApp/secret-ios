
import Foundation

/**
 * Handles reauthentication errors sent at the start of the flow.
 */

class AuthenticationStartReauthenticateErrorHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: (NSError?, Int)) -> [AuthenticationCoordinatorAction]? {
        let (optionalError, numberOfAccounts) = context

        // Only handle errors on launch
        guard case .start = currentStep else {
            return nil
        }

        // If there is no error, we don't need to reauthenticate
        guard let error = optionalError else {
            return nil
        }

        // Only handle reauthentication errors
        let supportedErrors: [ZMUserSessionErrorCode] = [
            .clientDeletedRemotely,
            .accessTokenExpired,
            .needsAuthenticationAfterReboot,
            .needsPasswordToRegisterClient
         ]

        guard supportedErrors.contains(error.userSessionErrorCode) else {
            return nil
        }

        guard numberOfAccounts >= 1 else {
            return nil
        }

        guard let loginCredentials = error.userInfo[ZMUserLoginCredentialsKey] as? LoginCredentials else {
            return nil
        }

        // Prepare the next step
        let nextStep = AuthenticationFlowStep.reauthenticate(credentials: loginCredentials, numberOfAccounts: numberOfAccounts, isSignedOut: true)
        return [.transition(nextStep, mode: .reset)]
    }

}
