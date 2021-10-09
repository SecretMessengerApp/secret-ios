
import Foundation

public let UIWindowLevelNotification: UIWindow.Level = UIWindow.Level.statusBar - 1
public let UIWindowLevelCallOverlay: UIWindow.Level = UIWindowLevelNotification - 1

final class CallWindow: UIWindow {
    let callController = CallWindowRootViewController()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        rootViewController = callController
        backgroundColor = .clear
        accessibilityIdentifier = "ZClientCallWindow"
        accessibilityViewIsModal = true
        windowLevel = UIWindowLevelCallOverlay
    }
    
    @available(*, unavailable) required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func hideWindowIfNeeded() {
        if rootViewController?.presentedViewController == nil {
            isHidden = true
        }
    }
}
