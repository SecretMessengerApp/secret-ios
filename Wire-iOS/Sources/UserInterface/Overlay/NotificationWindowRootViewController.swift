
import UIKit

final class NotificationWindowRootViewController: UIViewController {
    private(set) var appLockViewController: AppLockViewController?

    deinit {
        if appLockViewController?.parent == self {
            appLockViewController?.wr_removeFromParentViewController()
        }
    }

    override func loadView() {
        view = PassthroughTouchesView()

        appLockViewController = AppLockViewController.shared
        if nil != appLockViewController?.parent {
            appLockViewController?.wr_removeFromParentViewController()
        }

        add(appLockViewController, to: view)

        setupConstraints()
    }

    private func setupConstraints() {
        appLockViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        appLockViewController?.view.fitInSuperview()
    }

    // MARK: - Rotation handling (should match up with root)

    private func topmostViewController() -> UIViewController? {
        guard let topmostViewController = UIApplication.shared.topmostViewController() else { return nil}

        if topmostViewController != self && !(topmostViewController is NotificationWindowRootViewController) {
            return topmostViewController
        } else {
            return nil
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var shouldAutorotate: Bool {
        return topmostViewController()?.shouldAutorotate ?? true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topmostViewController()?.supportedInterfaceOrientations ?? wr_supportedInterfaceOrientations
    }

}

// MARK : - Child
fileprivate extension UIViewController {
    func wr_removeFromParentViewController() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

}
