
import UIKit

class RoundedView: UIView, RoundedViewProtocol {

    final override class var layerClass: AnyClass {
        return ContinuousMaskLayer.self
    }

    func toggleCircle() {
        shape = .circle
    }

    func toggleRectangle() {
        shape = .rectangle
    }

    func setRelativeCornerRadius(multiplier: CGFloat, dimension: MaskDimension) {
        shape = .relative(multiplier: multiplier, dimension: dimension)
    }


//    @objc public func setCornerRadius(_ cornerRadius: CGFloat) {
//        shape = .rounded(radius: cornerRadius)
//    }

    func setRoundedCorners(_ corners: UIRectCorner) {
        roundedCorners = corners
    }

}
