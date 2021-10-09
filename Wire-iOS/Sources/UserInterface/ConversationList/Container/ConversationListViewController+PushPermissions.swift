
import Foundation

extension ConversationListViewController: PermissionDeniedViewControllerDelegate {
    public func continueWithoutPermission(_ viewController: PermissionDeniedViewController) {
        closePushPermissionDeniedDialog()
    }
}

extension ConversationListViewController {

    func closePushPermissionDialogIfNotNeeded() {
        UNUserNotificationCenter.current().checkPushesDisabled({ pushesDisabled in
            if !pushesDisabled,
                let _ = self.pushPermissionDeniedViewController {
                DispatchQueue.main.async {
                    self.closePushPermissionDeniedDialog()
                }
            }
        })
    }

    func closePushPermissionDeniedDialog() {
        pushPermissionDeniedViewController?.willMove(toParent: nil)
        pushPermissionDeniedViewController?.view.removeFromSuperview()
        pushPermissionDeniedViewController?.removeFromParent()
        pushPermissionDeniedViewController = nil

        contentContainer.alpha = 1.0
    }

    func showPermissionDeniedViewController() {
        observeApplicationDidBecomeActive()

        let permissions = PermissionDeniedViewController.pushDeniedViewController()

        permissions.delegate = self

        addToSelf(permissions)

        permissions.view.translatesAutoresizingMaskIntoConstraints = false
        permissions.view.fitInSuperview()
        pushPermissionDeniedViewController = permissions

        concealContentContainer()
    }

    @objc func applicationDidBecomeActive(_ notif: Notification) {
        closePushPermissionDialogIfNotNeeded()
    }

    private func observeApplicationDidBecomeActive() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive(_:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

    }
}
