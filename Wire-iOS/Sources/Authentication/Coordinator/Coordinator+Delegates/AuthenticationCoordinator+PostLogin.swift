
import Foundation

extension AuthenticationCoordinator: PostLoginAuthenticationObserver {

    /// Called when the client is registered.
    func clientRegistrationDidSucceed(accountId: UUID) {
        eventResponderChain.handleEvent(ofType: .clientRegistrationSuccess)
    }

    /// Called when the client failed to register.
    func clientRegistrationDidFail(_ error: NSError, accountId: UUID) {
        eventResponderChain.handleEvent(ofType: .clientRegistrationError(error, accountId))
    }

    /// Called when the access token of the user is invalidated.
    func authenticationInvalidated(_ error: NSError, accountId: UUID) {
        authenticationDidFail(error)
    }

    /// Called when the account was deleted.
    func accountDeleted(accountId: UUID) {
        // no-op
    }

}
