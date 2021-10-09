
import UIKit

extension UINavigationController {
    func popToPrevious(of controller: UIViewController) -> [UIViewController]? {
        if let currentIdx = viewControllers.firstIndex(of: controller) {
            let previousIdx = currentIdx - 1
            if viewControllers.count > previousIdx {
                let previousController = viewControllers[previousIdx]
                return popToViewController(previousController, animated: true)
            }
        }
        return nil
    }
    
    open func pushViewController(_ viewController: UIViewController,
                            animated: Bool,
                            completion: (() -> Void)?) {
        pushViewController(viewController, animated: animated)
        
        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion?()
            }
        } else {
            completion?()
        }
    }

    @discardableResult
    func popViewController(animated: Bool,
                                                   completion: (() -> Void)?) -> UIViewController? {
        let controller = popViewController(animated: animated)
        
        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion?()
            }
        } else {
            completion?()
        }
        return controller
    }
    
    @discardableResult open func popToRootViewController(animated: Bool,
                                                         completion: (()-> Void)?) -> [UIViewController]? {
        let controllers = popToRootViewController(animated: true)
        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion?()
            }
        } else {
            completion?()
        }
        return controllers
    }

}
