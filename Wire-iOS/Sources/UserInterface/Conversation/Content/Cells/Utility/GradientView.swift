

import Foundation

 open class GradientView: UIView {
    override open class var layerClass : AnyClass {
        return CAGradientLayer.self;
    }
    
    open var gradientLayer: CAGradientLayer {
        get {
            if let gradientLayer = self.layer as? CAGradientLayer {
                return gradientLayer
            }
            fatalError("gradientLayer is missing: \(self.layer)")
        }
    }
    
    func setStartPoint(_ startPoint: CGPoint, endPoint: CGPoint, locations: [CGFloat]) {
        gradientLayer.locations = locations as [NSNumber]?
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
    }
}
