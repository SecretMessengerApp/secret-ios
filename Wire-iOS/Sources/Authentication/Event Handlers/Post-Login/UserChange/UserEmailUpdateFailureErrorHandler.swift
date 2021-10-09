
import Foundation

/**
 * Handles error when addding the e-mail to the user.
 */

class UserEmailUpdateFailureErrorHandler: AuthenticationEventHandler {

    weak var statusProvider: AuthenticationStatusProvider?

    func handleEvent(currentStep: AuthenticationFlowStep, context: NSError) -> [AuthenticationCoordinatorAction]? {
        let error = context as NSError

        // Only handle errors when updating the email
        guard case .registerEmailCredentials = currentStep else {
            return nil
        }

        // Provide actions
        var actions: [AuthenticationCoordinatorAction] = [.hideLoadingView]

        if (error as NSError).userSessionErrorCode == .emailIsAlreadyRegistered {
            let feedbackAction: AuthenticationCoordinatorAction = .executeFeedbackAction(.clearInputFields)
            actions.append(feedbackAction)
        }

        let errorAlert = AuthenticationCoordinatorErrorAlert(error: error, completionActions: [.unwindState(withInterface: false)])
        actions.append(.presentErrorAlert(errorAlert))

        return actions
    }

}
