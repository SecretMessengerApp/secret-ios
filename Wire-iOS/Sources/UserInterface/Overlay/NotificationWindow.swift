
import UIKit

final class NotificationWindow: UIWindow {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        rootViewController = NotificationWindowRootViewController()
        backgroundColor = .clear
        accessibilityIdentifier = "ZClientNotificationWindow"
        accessibilityViewIsModal = true
        windowLevel = UIWindowLevelNotification // status bar level - 1
        isOpaque = false
    }
    
    @available(*, unavailable) required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
