

import UIKit

final class ZoomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private var interactionPoint = CGPoint.zero
    private var reversed = false

    init(interactionPoint: CGPoint, reversed: Bool) {
        super.init()

        self.interactionPoint = interactionPoint
        self.reversed = reversed
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.65
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toView = transitionContext.toView
        let fromView = transitionContext.fromView
        let containerView = transitionContext.containerView

        if let toView = toView {
            containerView.addSubview(toView)
        }

        if !transitionContext.isAnimated {
            transitionContext.completeTransition(true)
            return
        }

        containerView.layoutIfNeeded()

        fromView?.alpha = 1
        fromView?.layer.needsDisplayOnBoundsChange = false

        if reversed {

            UIView.animate(easing: .easeInExpo, duration: 0.35, animations: {
                fromView?.alpha = 0
                fromView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }) { finished in
                fromView?.transform = .identity
            }

            toView?.alpha = 0
            toView?.transform = CGAffineTransform(scaleX: 2, y: 2)

            UIView.animate(easing: .easeOutExpo, duration: 0.35, animations: {
                toView?.alpha = 1
                toView?.transform = .identity
            }) { finished in
                transitionContext.completeTransition(true)
            }
        } else {

            if let frame = fromView?.frame {
                fromView?.layer.anchorPoint = interactionPoint
                fromView?.frame = frame
            }

            UIView.animate(easing: .easeInExpo, duration: 0.35, animations: {
                fromView?.alpha = 0
                fromView?.transform = CGAffineTransform(scaleX: 2, y: 2)
            }) { finished in
                fromView?.transform = .identity
            }

            if let frame = toView?.frame  {
                toView?.layer.anchorPoint = interactionPoint
                toView?.frame = frame
            }

            toView?.alpha = 0
            toView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

            UIView.animate(easing: .easeOutExpo, duration: 0.35, delayTime: 0.3, animations: {
                toView?.alpha = 1
                toView?.transform = .identity
            }) { finished in
                transitionContext.completeTransition(true)
            }
        }
    }
}
