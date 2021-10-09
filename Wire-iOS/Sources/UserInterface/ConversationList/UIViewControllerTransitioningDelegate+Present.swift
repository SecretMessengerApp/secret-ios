

import Foundation

extension UIViewControllerTransitioningDelegate where Self: UIViewController {
    func show(_ viewController: UIViewController,
              animated: Bool, completion: (() -> ())?) {
        viewController.transitioningDelegate = self
        viewController.modalPresentationStyle = .currentContext

        present(viewController, animated: animated, completion: completion)
    }
}
