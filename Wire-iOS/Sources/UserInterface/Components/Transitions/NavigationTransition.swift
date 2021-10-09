
import UIKit

final class NavigationTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let operation: UINavigationController.Operation
    
    init?(operation: UINavigationController.Operation) {
        guard operation == .push || operation == .pop else { return nil }
        self.operation = operation
        
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.55
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.fromView,
            let toView = transitionContext.toView,
            let fromViewController = transitionContext.fromViewController,
            let toViewController = transitionContext.toViewController else {
                return
        }

        let containerView = transitionContext.containerView

        let initialFrameFromViewController = transitionContext.initialFrame(for: fromViewController)
        let finalFrameToViewController = transitionContext.finalFrame(for: toViewController)

        let offscreenRight = CGAffineTransform(translationX: initialFrameFromViewController.size.width, y: 0)
        let offscreenLeft = CGAffineTransform(translationX: -(initialFrameFromViewController.size.width), y: 0)

        let toViewStartTransform: CGAffineTransform
        let fromViewEndTransform: CGAffineTransform

        switch operation {
        case .push:
            toViewStartTransform = rightToLeft ? offscreenLeft : offscreenRight
            fromViewEndTransform = rightToLeft ? offscreenRight : offscreenLeft
        case .pop:
            toViewStartTransform = rightToLeft ? offscreenRight : offscreenLeft
            fromViewEndTransform = rightToLeft ? offscreenLeft : offscreenRight
        default:
            return
        }

        fromView.frame = initialFrameFromViewController
        toView.frame = finalFrameToViewController
        toView.transform = toViewStartTransform

        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        
        containerView.layoutIfNeeded()

        UIView.animate(easing: .easeOutExpo,
                          duration: transitionDuration(using: transitionContext),
                          animations: {
            fromView.transform = fromViewEndTransform
            toView.transform = .identity
        }) { finished in
            fromView.transform = .identity
            transitionContext.completeTransition(true)
        }
    }

    private var rightToLeft: Bool {
        return UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
    }
}
