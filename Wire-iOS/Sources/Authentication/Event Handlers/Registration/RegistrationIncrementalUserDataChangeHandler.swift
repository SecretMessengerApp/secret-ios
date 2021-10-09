
import Foundation

/**
 * Handles the change of user data during registration.
 */

class RegistrationIncrementalUserDataChangeHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: Void) -> [AuthenticationCoordinatorAction]? {
        // Only handle data change during incremental creation step
        guard case let .incrementalUserCreation(unregisteredUser, _) = currentStep else {
            return nil
        }
        
        // Check for missing requirements before allowing the user to register.

        if unregisteredUser.marketingConsent == nil {
            return handleMissingMarketingConsent(with: unregisteredUser)
//            return [.hideLoadingView, .setMarketingConsent(false)]
        } else if unregisteredUser.name == nil {
            return requestIntermediateStep(.setName, with: unregisteredUser)

        } else if unregisteredUser.password == nil && unregisteredUser.needsPassword {
            return requestIntermediateStep(.setPassword, with: unregisteredUser)

        } else {
            return handleRegistrationCompletion(with: unregisteredUser)
        }
    }

    // MARK: - Specific Flow Handlers

    private func requestIntermediateStep(_ step: IntermediateRegistrationStep, with user: UnregisteredUser) -> [AuthenticationCoordinatorAction] {
        let flowStep = AuthenticationFlowStep.incrementalUserCreation(user, step)
        return [.hideLoadingView, .transition(flowStep, mode: .reset)]
    }

    private func handleMissingMarketingConsent(with user: UnregisteredUser) -> [AuthenticationCoordinatorAction] {
        // Alert Actions
        let privacyPolicyAction = AuthenticationCoordinatorAlertAction(title: "news_offers.consent.button.privacy_policy.title".localized, coordinatorActions: [.openURL(URL.wr_privacyPolicy.appendingLocaleParameter)])
        let declineAction = AuthenticationCoordinatorAlertAction(title: "general.decline".localized, coordinatorActions: [.setMarketingConsent(false)])
        let acceptAction = AuthenticationCoordinatorAlertAction(title: "general.accept".localized, coordinatorActions: [.setMarketingConsent(true)])

        // Alert
        let alert = AuthenticationCoordinatorAlert(title: "news_offers.consent.title".localized, message: "news_offers.consent.message".localized, actions: [privacyPolicyAction, declineAction, acceptAction])

        return [.hideLoadingView, .presentAlert(alert)]
    }

    private func handleRegistrationCompletion(with user: UnregisteredUser) -> [AuthenticationCoordinatorAction] {
        return [.showLoadingView, .completeUserRegistration]
    }

}
