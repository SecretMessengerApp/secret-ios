

import UIKit
import Cartography

extension ConversationListViewController {

    func removeUsernameTakeover() {
        guard let takeover = usernameTakeoverViewController else { return }
        takeover.willMove(toParent: nil)
        takeover.view.removeFromSuperview()
        takeover.removeFromParent()
        contentContainer.alpha = 1
        usernameTakeoverViewController = nil

        if parent?.presentedViewController is SettingsStyleNavigationController {
            parent?.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }

    func openChangeHandleViewController(with handle: String) {
        // We need to ensure we are currently showing the takeover as this
        // callback will also get invoked when changing the handle from the settings view controller.
        guard !(parent?.presentedViewController is SettingsStyleNavigationController) else { return }
        guard nil != usernameTakeoverViewController else { return }

        let handleController = ChangeHandleViewController(suggestedHandle: handle)
        handleController.popOnSuccess = false
        handleController.view.backgroundColor = .black
        let navigationController = SettingsStyleNavigationController(rootViewController: handleController)
        navigationController.modalPresentationStyle = .formSheet
        navigationController.navigationBar.setBackgroundImage(UIImage.init(color: .black, andSize: CGSize(width: UIScreen.main.bounds.width, height: 44)), for: UIBarMetrics.default)
        parent?.present(navigationController, animated: true, completion: nil)
    }

    func showUsernameTakeover(suggestedHandle: String, name: String) {
        guard nil == usernameTakeoverViewController else { return }

        let usernameTakeoverViewController = UserNameTakeOverViewController(suggestedHandle: suggestedHandle, name: name)
        usernameTakeoverViewController.delegate = viewModel

        addToSelf(usernameTakeoverViewController)
        concealContentContainer()

        constrain(view, usernameTakeoverViewController.view) { view, takeover in
            takeover.edges == view.edges
        }

        self.usernameTakeoverViewController = usernameTakeoverViewController
    }

    func concealContentContainer() {
        contentContainer.alpha = 0
    }

    func showNewsletterSubscriptionDialogIfNeeded(completionHandler: @escaping ResultHandler) {
        UIAlertController.showNewsletterSubscriptionDialogIfNeeded(presentViewController: self, completionHandler: completionHandler)        
    }
}
