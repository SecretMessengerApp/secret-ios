
import Foundation
import UIKit

protocol VerticalTransitionDataSource: NSObject {
    func viewsToHideDuringVerticalTransition(transition: VerticalTransition) -> [UIView]
}

final class VerticalTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let offset: CGFloat
    weak var dataSource: VerticalTransitionDataSource?
    
    init(offset: CGFloat) {
        self.offset = offset
        
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.55
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let toView = transitionContext.toView,
              let toViewController = transitionContext.toViewController else { return }
        
        guard let fromView = transitionContext.fromView,
              let fromViewController = transitionContext.fromViewController else { return }
        
        fromView.frame = transitionContext.initialFrame(for: fromViewController)
        
        containerView.addSubview(toView)

        if !transitionContext.isAnimated {
            transitionContext.completeTransition(true)
            return
        }
        
        containerView.layoutIfNeeded()
        
        let sign = copysign(1.0, self.offset)
        let finalRect = transitionContext.finalFrame(for: toViewController)
        let toTransfrom = CGAffineTransform(translationX: 0, y: -self.offset)
        let fromTransform = CGAffineTransform(translationX: 0, y: sign * (finalRect.size.height - abs(self.offset)))
        
        toView.transform = toTransfrom
        fromView.transform = fromTransform
        
        if let viewsToHide = dataSource?.viewsToHideDuringVerticalTransition(transition: self) {
            viewsToHide.forEach { $0.isHidden = true }
        }
      
        UIView.animate(easing: EasingFunction.easeOutExpo, duration: transitionDuration(using: transitionContext), animations: {
            fromView.transform = CGAffineTransform(translationX: 0.0, y: sign * finalRect.size.height)
            toView.transform = CGAffineTransform.identity
        }) { (finished) in
            fromView.transform = CGAffineTransform.identity
            if let viewsToHide = self.dataSource?.viewsToHideDuringVerticalTransition(transition: self) {
                viewsToHide.forEach { $0.isHidden = false }
            }
            
            transitionContext.completeTransition(true)
        }
    }
}
