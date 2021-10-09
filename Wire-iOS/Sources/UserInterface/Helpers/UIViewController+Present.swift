
import Foundation

extension UIViewController {

    /// present self from the top most view controller
    ///
    /// - Parameters:
    ///   - flag: true if animated
    ///   - completion: the completion closure
    func presentTopmost(animated flag: Bool = true,
                        completion: (() -> Void)? = nil) {
        UIApplication.shared.topmostViewController(onlyFullScreen: false)?.present(self, animated: flag, completion: completion)
    }

    @objc
    func presentInNotificationsWindow() {
        AppDelegate.shared.notificationsWindow?.rootViewController?.present(self, animated: true)
    }
}
