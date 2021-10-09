
import Foundation

/**
 * Handles the change of email of the user when logging in.
 */

class UserEmailChangeEventHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: UserChangeInfo) -> [AuthenticationCoordinatorAction]? {
        let changeInfo = context

        // Only execute actions if the profile has changed.
        guard changeInfo.profileInformationChanged else {
            return nil
        }

        // Only look for email changes in the email link step
        guard case .pendingEmailLinkVerification = currentStep else {
            return nil
        }

        // Verify state
        guard let selfUser = statusProvider?.selfUser else {
            return nil
        }

        guard selfUser.emailAddress?.isEmpty == false else {
            return nil
        }

        // Complete the login flow when the user finished adding email
        return [.hideLoadingView, .completeLoginFlow]
    }

}
