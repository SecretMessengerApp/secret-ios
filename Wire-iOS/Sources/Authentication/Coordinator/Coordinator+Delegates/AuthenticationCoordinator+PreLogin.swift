
import Foundation

extension AuthenticationCoordinator: PreLoginAuthenticationObserver {

    /// Called when the authentication succeeds. We ignore this event, as
    /// we are waiting for the client registration event to fire to transition to the next step.
    func authenticationDidSucceed() {
        log.info("Received \"authentication did succeed\" event. Ignoring, waiting for client registration event.")
    }

    /// Called when the credentials could not be authenticated.
    func authenticationDidFail(_ error: NSError) {
        eventResponderChain.handleEvent(ofType: .authenticationFailure(error))
    }

    /// Called when the backup is ready to be imported.
    func authenticationReadyToImportBackup(existingAccount: Bool) {
        addedAccount = !existingAccount
        eventResponderChain.handleEvent(ofType: .backupReady(existingAccount))
    }

    /// Called when the phone login called became available.
    func loginCodeRequestDidSucceed() {
        eventResponderChain.handleEvent(ofType: .loginCodeAvailable)
    }

    /// Called when the phone login code couldn't be requested manually.
    func loginCodeRequestDidFail(_ error: NSError) {
        eventResponderChain.handleEvent(ofType: .authenticationFailure(error))
    }

}
