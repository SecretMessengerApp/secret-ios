
import Foundation
import UIKit

enum EasingFunction: Int {
    case linear
    case easeInSine
    case easeOutSine
    case easeInOutSine
    case easeInQuad
    case easeOutQuad
    case easeInOutQuad
    case easeInCubic
    case easeOutCubic
    case easeInOutCubic
    case easeInQuart
    case easeOutQuart
    case easeInOutQuart
    case easeInQuint
    case easeOutQuint
    case easeInOutQuint
    case easeInExpo
    case easeOutExpo
    case easeInOutExpo
    case easeInCirc
    case easeOutCirc
    case easeInOutCirc
    case easeInBack
    case easeOutBack
    case easeInOutBack
}

extension UIView {
    
    class func animate(
        easing: EasingFunction,
        duration: TimeInterval,
        delayTime: TimeInterval = 0,
        animations: @escaping () -> Void,
        completion: ResultHandler? = nil
    ) {
        let closure = {
            CATransaction.begin()
            CATransaction.setAnimationDuration(duration)
            CATransaction.setAnimationTimingFunction(easing.timingFunction)
            
            UIView.animate(withDuration: duration, animations: animations, completion: completion)
            
            CATransaction.commit()
        }
        
        
        if delayTime > 0 {
            delay(delayTime, closure: closure)
        } else {
            closure()
        }
    }
}


