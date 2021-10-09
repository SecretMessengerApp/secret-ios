
import UIKit

class CallQualityDismissalTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.55
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let callQualityVC = transitionContext.viewController(forKey: .from) as? CallQualityViewController else {
            return
        }
        
        let containerView = transitionContext.containerView
        let contentView = callQualityVC.contentView
        let dimmingView = callQualityVC.dimmingView
        
        // Animate Presentation

        let hideTransform: CGAffineTransform
        
        switch containerView.traitCollection.horizontalSizeClass {
        case .regular:
            hideTransform = CGAffineTransform(scaleX: 0, y: 0)
            
        default:
            hideTransform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
        }
        
        let duration = transitionDuration(using: transitionContext)

        let animations = {
            dimmingView.alpha = 0
            contentView.transform = hideTransform
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .systemDismissalCurve, animations: animations) { finished in
            transitionContext.completeTransition((transitionContext.transitionWasCancelled == false) && finished)
        }
        
    }
    
}
