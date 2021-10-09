
import UIKit

extension CABasicAnimation {
    convenience init(rotationSpeed: CFTimeInterval,
                     beginTime: CFTimeInterval,
                     delegate: CAAnimationDelegate? = nil) {
        self.init(keyPath: "transform.rotation")

        fillMode = .forwards
        self.delegate = delegate
        
        // (2PI is a full turn, so pi is a half turn)
        toValue = Double.pi
        repeatCount = .greatestFiniteMagnitude
        
        duration = rotationSpeed / 2
        self.beginTime = beginTime
        isCumulative = true
        timingFunction = CAMediaTimingFunction(name: .linear)
    }
}
