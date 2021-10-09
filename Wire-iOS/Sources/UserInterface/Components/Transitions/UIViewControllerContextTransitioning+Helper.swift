

import Foundation
import UIKit

extension UIViewControllerContextTransitioning {
    
    var fromView: UIView? {
        view(forKey: .from)
    }
    
    var toView: UIView? {
        let returnView = view(forKey: .to)
        
        if let view = viewController(forKey: .to) {
            returnView?.frame = finalFrame(for: view)
        }
        
        return returnView
    }
    
    var fromViewController: UIViewController? {
        viewController(forKey: .from)
    }
    
    var toViewController: UIViewController? {
        viewController(forKey: .to)
    }
}
