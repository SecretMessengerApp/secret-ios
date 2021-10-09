
import UIKit

extension UIViewController {

    /// Returns whether the view controller can be dismissed.
    var canBeDismissed: Bool {
        return presentedViewController != nil ||
            presentingViewController?.presentedViewController == self
            || (navigationController != nil && navigationController?.presentingViewController?.presentedViewController == navigationController)
    }

    /// Dismisses the view controller if needed before performing the specified actions.
    func dismissIfNeeded(animated: Bool = true,
                         completion: (() -> Void)? = nil) {
        if canBeDismissed {
            dismiss(animated: animated, completion: completion)
        } else {
            completion?()
        }
    }

    func dismissToRootVC(animated: Bool, completion: @escaping (() -> Void)) {
        var vc = self
        while let presentingVC = vc.presentingViewController {
            vc = presentingVC
        }
        vc.dismiss(animated: animated, completion: completion)
    }
}
