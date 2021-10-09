
import Foundation

/**
 * Handles client registration errors related to the client limit.
 */

class AuthenticationClientLimitErrorHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: (NSError, UUID)) -> [AuthenticationCoordinatorAction]? {
        let (error, _) = context

        // Only handle canNotRegisterMoreClients errors
        guard error.userSessionErrorCode == .canNotRegisterMoreClients else {
            return nil
        }

        // Get the credentials to start the deletion
        let authenticationCredentials: ZMCredentials?

        switch currentStep {
        case .noHistory(let credentials, _):
            authenticationCredentials = credentials
        case .authenticateEmailCredentials(let credentials):
            authenticationCredentials = credentials
        default:
            authenticationCredentials = nil
        }

        guard let nextStep = AuthenticationFlowStep.makeClientManagementStep(from: error, credentials: authenticationCredentials, statusProvider: self.statusProvider) else {
            return nil
        }

        return [.hideLoadingView, .transition(nextStep, mode: .reset)]
    }

}
