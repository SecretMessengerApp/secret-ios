
import Foundation

/**
 * Handles client registration errors related to the expiration of the auth token, which requires
 * the user to reauthenticate.
 */

class AuthenticationNeedsReauthenticationErrorHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: (NSError, UUID)) -> [AuthenticationCoordinatorAction]? {
        let (error, _) = context

        // Only handle needsPasswordToRegisterClient errrors
        guard error.userSessionErrorCode == .needsPasswordToRegisterClient else {
            return nil
        }
        
        var isSignedOut: Bool = true
        
        // If the error comes from the "no history" step, it means that we show
        // the "password needed" screen, and that we should hide the "your session
        // is expired" text.
        if case .noHistory = currentStep {
            isSignedOut = false
        }
        
        let numberOfAccounts = statusProvider?.numberOfAccounts ?? 0
        let credentials = error.userInfo[ZMUserLoginCredentialsKey] as? LoginCredentials

        let nextStep = AuthenticationFlowStep.reauthenticate(credentials: credentials, numberOfAccounts: numberOfAccounts, isSignedOut: isSignedOut)

        let alert = AuthenticationCoordinatorAlert(title: "registration.signin.alert.password_needed.title".localized,
                                                   message: "registration.signin.alert.password_needed.message".localized,
                                                   actions: [.ok])

        return [.hideLoadingView, .transition(nextStep, mode: .reset), .presentAlert(alert)]
    }

}
