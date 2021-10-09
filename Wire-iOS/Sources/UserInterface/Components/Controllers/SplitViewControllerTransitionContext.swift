
import Foundation
import UIKit

final class SplitViewControllerTransitionContext: NSObject, UIViewControllerContextTransitioning {

    var completionBlock: ((_ didComplete: Bool) -> Void)?
    var isAnimated = false
    var isInteractive = false
    let containerView: UIView
    var presentationStyle: UIModalPresentationStyle = .custom

    private var viewControllers: [UITransitionContextViewControllerKey: UIViewController] = [:]

    init(from fromViewController: UIViewController?,
         to toViewController: UIViewController?,
         containerView: UIView) {
        self.containerView = containerView

        super.init()

        if fromViewController != nil {
            viewControllers[.from] = fromViewController
        }

        if toViewController != nil {
            viewControllers[.to] = toViewController
        }
    }

    func initialFrame(for viewController: UIViewController) -> CGRect {
        return containerView.bounds
    }

    func finalFrame(for viewController: UIViewController) -> CGRect {
        return containerView.bounds
    }

    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        return viewControllers[key]
    }

    func view(forKey key: UITransitionContextViewKey) -> UIView? {

        let transitionContextViewControllerKey: UITransitionContextViewControllerKey
        switch key {
        case .to:
            transitionContextViewControllerKey = .to
        case .from:
            transitionContextViewControllerKey = .from
        default:
            return nil
        }

        return viewControllers[transitionContextViewControllerKey]?.view
    }

    func completeTransition(_ didComplete: Bool) {
        completionBlock?(didComplete)
    }

    var transitionWasCancelled: Bool {
        return false
        // Our non-interactive transition can't be cancelled (it could be interrupted, though)
    }

    // Supress warnings by implementing empty interaction methods for the remainder of the protocol:
    var targetTransform: CGAffineTransform {
        return .identity
    }

    func updateInteractiveTransition(_ percentComplete: CGFloat) {
        //no-op
    }

    func finishInteractiveTransition() {
        //no-op
    }

    func cancelInteractiveTransition() {
        //no-op
    }

    func pauseInteractiveTransition() {
        //no-op
    }

}
