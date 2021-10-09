

import Foundation


extension UIView {
    
    public func updateVisibleViews(_ views: [UIView], visibleViews: [UIView], animated: Bool) {
        if (animated) {
            UIView.transition(with: self, duration: 0.35, options: .transitionCrossDissolve, animations: {
                self.updateVisibleViews(views, visibleViews: visibleViews)
                }, completion: nil)
        } else {
            self.updateVisibleViews(views, visibleViews: visibleViews)
        }
    }
    
    public func updateVisibleViews(_ views: [UIView], visibleViews: [UIView]) {
        let allViews = Set(views)
        let hiddenViews = allViews.subtracting(visibleViews)
        
        visibleViews.forEach { $0.isHidden = false }
        hiddenViews.forEach { $0.isHidden = true }
    }
    
}
