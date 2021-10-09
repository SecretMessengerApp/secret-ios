
import Foundation

/**
 * Handles the notification informing the user that backups are ready to be imported.
 */

class AuthenticationBackupReadyEventHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Bool) -> [AuthenticationCoordinatorAction]? {
        let existingAccount = context

        // Automatically complete the backup for @fastLogin automation
        guard AutomationHelper.sharedHelper.automationEmailCredentials == nil else {
            return [.showLoadingView, .configureNotifications, .completeBackupStep]
        }

        // Get the signed-in user credentials
        let authenticationCredentials: ZMCredentials?

        switch currentStep {
        case .authenticateEmailCredentials(let credentials):
            authenticationCredentials = credentials
        case .authenticatePhoneCredentials(let credentials):
            authenticationCredentials = credentials
        case .companyLogin:
            authenticationCredentials = nil
        case .noHistory:
            return [.hideLoadingView]
        default:
            return nil
        }

        // Prepare the backup step
        let context: NoHistoryContext = existingAccount ? .loggedOut : .newDevice
        let nextStep = AuthenticationFlowStep.noHistory(credentials: authenticationCredentials, context: context)

        return [.hideLoadingView, .transition(nextStep, mode: .reset)]
    }

}
