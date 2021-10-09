
import Foundation

typealias AccentColorChangeHandlerBlock = (UIColor?, Any?) -> Void

final class AccentColorChangeHandler: NSObject, ZMUserObserver {

    private var handlerBlock: AccentColorChangeHandlerBlock?
    private var observer: Any?
    private var userObserverToken: Any?
    
    class func addObserver(_ observer: Any?, handlerBlock changeHandler: @escaping AccentColorChangeHandlerBlock) -> Self {
        return self.init(observer: observer, handlerBlock: changeHandler)
    }
    
    init(observer: Any?, handlerBlock changeHandler: @escaping AccentColorChangeHandlerBlock) {
        super.init()
        handlerBlock = changeHandler
        self.observer = observer

        if let selfUser = SelfUser.provider?.selfUser, let userSession = ZMUserSession.shared() {
            userObserverToken = UserChangeInfo.add(observer: self, for: selfUser, userSession: userSession)
        }
    }
    
    deinit {
        observer = nil
    }
    
    func userDidChange(_ change: UserChangeInfo) {
        if change.accentColorValueChanged {
            handlerBlock?(change.user.accentColor, observer)
        }
    }
}
