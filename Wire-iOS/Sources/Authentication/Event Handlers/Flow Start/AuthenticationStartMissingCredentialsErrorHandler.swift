
import Foundation

class AuthenticationStartMissingCredentialsErrorHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: (NSError?, Int)) -> [AuthenticationCoordinatorAction]? {
        let error = context.0

        // Only handle errors on start
        guard case .start = currentStep else {
            return nil
        }

        // Only handle missing credentials error
        guard error?.userSessionErrorCode == .needsToRegisterEmailToRegisterClient else {
            return nil
        }

        guard statusProvider?.selfUser != nil && statusProvider?.selfUserProfile != nil else {
            return nil
        }

        // Prepare the next step
        return [.startPostLoginFlow, .transition(.addEmailAndPassword, mode: .reset)]
    }

}
