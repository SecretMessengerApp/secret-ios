
import Foundation

class BlurEffectTransition : NSObject, UIViewControllerAnimatedTransitioning {
    
    let reverse : Bool
    let visualEffectView: UIVisualEffectView
    let crossfadingViews: [UIView]
    
    init(visualEffectView: UIVisualEffectView, crossfadingViews: [UIView], reverse : Bool) {
        self.reverse = reverse
        self.visualEffectView = visualEffectView
        self.crossfadingViews = crossfadingViews
        
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if let toView = transitionContext.view(forKey: UITransitionContextViewKey.to),
            let toViewController = transitionContext.viewController(forKey: .to) {
            
            toView.frame = transitionContext.finalFrame(for: toViewController)
            transitionContext.containerView.addSubview(toView)
        }
        
        if !transitionContext.isAnimated {
            transitionContext.completeTransition(true)
            return
        }
        
        transitionContext.view(forKey: UITransitionContextViewKey.to)?.layoutIfNeeded()
        
        let visualEffect = self.visualEffectView.effect
        
        if reverse {
            UIView.animate(withDuration: 0.35, animations: {
                self.crossfadingViews.forEach({ (view) in
                    view.alpha = 0
                })
                
                self.visualEffectView.effect = nil
            }, completion: { (didComplete) in
                self.visualEffectView.effect = visualEffect
                transitionContext.completeTransition(didComplete)
            })
        } else {
            self.visualEffectView.effect = nil
            self.crossfadingViews.forEach({ (view) in
                view.alpha = 0
            })
            
            UIView.animate(withDuration: 0.35, animations: {
                self.crossfadingViews.forEach({ (view) in
                    view.alpha = 1
                })
                
                self.visualEffectView.effect = visualEffect
            }, completion: { (didComplete) in
                transitionContext.completeTransition(didComplete)
            })
        }
    }
    
}
