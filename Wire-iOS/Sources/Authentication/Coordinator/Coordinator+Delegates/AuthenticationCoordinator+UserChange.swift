
import Foundation

extension AuthenticationCoordinator: UserProfileUpdateObserver, ZMUserObserver {

    func emailUpdateDidFail(_ error: Error!) {
        eventResponderChain.handleEvent(ofType: .authenticationFailure(error as NSError))
    }

    func didSendVerificationEmail() {
        eventResponderChain.handleEvent(ofType: .loginCodeAvailable)
    }

    func userDidChange(_ changeInfo: UserChangeInfo) {
        eventResponderChain.handleEvent(ofType: .userProfileChange(changeInfo))
    }

}
