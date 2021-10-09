
import Foundation

/**
 * Handles requests to add a new user account.
 */

class AuthenticationStartAddAccountEventHandler: AuthenticationEventHandler {

    let featureProvider: AuthenticationFeatureProvider
    weak var statusProvider: AuthenticationStatusProvider?

    init(featureProvider: AuthenticationFeatureProvider) {
        self.featureProvider = featureProvider
    }

    func handleEvent(currentStep: AuthenticationFlowStep, context: (NSError?, Int)) -> [AuthenticationCoordinatorAction]? {
        if featureProvider.allowOnlyEmailLogin {
            // Hide the landing screen if account creation is disabled.
            return [.transition(.provideCredentials(.email, nil), mode: .reset)]
        } else {
            return [.transition(.landingScreen, mode: .reset)]
        }
    }

}
