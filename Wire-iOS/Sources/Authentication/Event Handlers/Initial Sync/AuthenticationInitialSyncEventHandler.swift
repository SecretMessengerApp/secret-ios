
import Foundation

/**
 * Handles the initial sync event.
 */

class AuthenticationInitialSyncEventHandler: NSObject, AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Void) -> [AuthenticationCoordinatorAction]? {
        // Skip email/password prompt for @fastLogin automation
        guard AutomationHelper.sharedHelper.automationEmailCredentials == nil else {
            return [.hideLoadingView, .completeLoginFlow]
        }

        // Do not ask for credentials again (slow sync can be called multiple times)
        guard case let .pendingInitialSync(nextRegistrationStep) = currentStep else {
            return [.hideLoadingView]
        }

        // Check the registration status
        let isRegistered = statusProvider?.authenticatedUserWasRegisteredOnThisDevice == true

        // Build the list of actions
        var actions: [AuthenticationCoordinatorAction] = [.hideLoadingView]

        if isRegistered {
            actions.append(.assignRandomProfileImage)
        }

        if let nextStep = nextRegistrationStep {
            actions.append(.transition(nextStep, mode: .reset))
        } else {
            actions.append(isRegistered ? .completeRegistrationFlow : .completeLoginFlow)
        }

        return actions
    }

}
