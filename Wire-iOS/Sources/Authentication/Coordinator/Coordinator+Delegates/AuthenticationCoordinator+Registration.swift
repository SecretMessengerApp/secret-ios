
import Foundation

extension AuthenticationCoordinator: RegistrationStatusDelegate {

    /// Called when registration fails.
    func userRegistrationFailed(with error: Error) {
        eventResponderChain.handleEvent(ofType: .registrationError(error as NSError))
    }

    /// Called when registration fails.
    func teamRegistrationFailed(with error: Error) {
        eventResponderChain.handleEvent(ofType: .registrationError(error as NSError))
    }

    /// Called when the validation code for the registered credential was sent.
    func activationCodeSent() {
        eventResponderChain.handleEvent(ofType: .registrationStepSuccess)
    }

    /// Called when the validation code for the registered phone number was sent.
    func activationCodeSendingFailed(with error: Error) {
        eventResponderChain.handleEvent(ofType: .registrationError(error as NSError))
    }

    /// Called when the phone number verification succeeds.
    func activationCodeValidated() {
        eventResponderChain.handleEvent(ofType: .registrationStepSuccess)
    }

    /// Called when the phone verification fails.
    func activationCodeValidationFailed(with error: Error) {
        eventResponderChain.handleEvent(ofType: .registrationError(error as NSError))
    }

    /// Called when the user is registered.
    func userRegistered() {
        // no-op, handled in the event responder chain
    }

    /// Called when the team is registered.
    func teamRegistered() {
        // no-op, handled in the event responder chain
    }

}
