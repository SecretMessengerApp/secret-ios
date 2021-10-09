
import UIKit

extension AuthenticationCoordinator: UINavigationControllerDelegate {

    /**
     * Called when the navigation stack changes.
     *
     * There are three scenarios where this method can be called: pushing, popping and setting view controllers.
     *
     * When a new view controller is **pushed** or the stack is set, the state has already been updated, and the `currentViewController`
     * is equal to the view controller being pushed. We don't need to change the state.
     *
     * When the current view controller is **popped**, the state hasn't been updated (because it comes from user interaction),
     * so we need to unwind the state and update the current view controller to the one that is currently visible. In this case,
     * the view controller passed by the navigation controller is not equal to the `currentViewController`.
     */

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        defer {
            detectLoginCodeIfPossible()
        }

        // Detect if we are popping the durrent view controller

        guard
            let currentViewController = self.currentViewController,
            let authenticationViewController = viewController as? AuthenticationStepViewController else {
            return
        }

        // If we are popping, the new view controller won't be equal to the current view controller
        guard authenticationViewController.isEqual(currentViewController) == false else {
            return
        }

        self.currentViewController = authenticationViewController
        stateController.unwindState()
    }

}
