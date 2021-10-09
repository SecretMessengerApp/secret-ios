
import UIKit

class CallQualityPresentationTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.55
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let callQualityVC = transitionContext.viewController(forKey: .to) as? CallQualityViewController else {
            return
        }
        
        // Prepare view hierarchy
        
        let containerView = transitionContext.containerView
        let toView = callQualityVC.view!
        let contentView = callQualityVC.contentView
        let dimmingView = callQualityVC.dimmingView
        
        containerView.addSubview(toView)
        callQualityVC.updateLayout(for: containerView.traitCollection)

        switch containerView.traitCollection.horizontalSizeClass {
        case .regular:
            contentView.transform = CGAffineTransform(scaleX: 0, y: 0)
            
        default:
            contentView.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
        }
        
        // Animate Presentation
        
        let duration = transitionDuration(using: transitionContext)

        let animations = {
            dimmingView.alpha = 1
            contentView.transform = .identity
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .systemPresentationCurve, animations: animations) { finished in
            transitionContext.completeTransition((transitionContext.transitionWasCancelled == false) && finished)
        }
        
    }
    
}
