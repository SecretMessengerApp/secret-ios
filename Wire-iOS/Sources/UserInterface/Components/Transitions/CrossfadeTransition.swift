
import UIKit

final class CrossfadeTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval

    init(duration: TimeInterval = 0.35) {
        self.duration = duration
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.toView
        let fromView = transitionContext.fromView

        let containerView = transitionContext.containerView

        if let toView = toView {
            containerView.addSubview(toView)
        }

        if !transitionContext.isAnimated || duration == 0 {
            transitionContext.completeTransition(true)
            return
        }
        
        containerView.layoutIfNeeded()

        toView?.alpha = 0

        UIView.animate(easing: .easeInOutQuad, duration: duration, animations: {
            fromView?.alpha = 0
            toView?.alpha = 1
        }) { finished in
            transitionContext.completeTransition(true)
        }
    }
}
