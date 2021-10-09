
import Foundation

extension ZClientViewController: ZMUserObserver {
    
    public func userDidChange(_ changeInfo: UserChangeInfo) {
        if changeInfo.accentColorValueChanged {
            UIApplication.shared.keyWindow?.tintColor = UIColor.accent()
        }
    }

    func setupUserChangeInfoObserver() {
        guard let userSession = ZMUserSession.shared() else { return }
        userObserverToken = UserChangeInfo.add(observer: self, for: ZMUser.selfUser(), userSession: userSession)
    }

}
