
import UIKit

/**
 * A view with rounded corners. Adopt this protocol if your view's layer is a `ContinuousMaskLayer`.
 * This protocol provides utilities to easily change the rounded corners.
 *
 * You need to override `+ (Class *)layerClass` on `UIView` before conforming to this protocol.
 */

 protocol RoundedViewProtocol: NSObjectProtocol {
    var layer: CALayer { get }
}

extension RoundedViewProtocol {

    var shape: MaskShape {
        get {
            return roundedLayer.shape
        }
        set {
            roundedLayer.shape = newValue
        }
    }

    var roundedCorners: UIRectCorner {
        get {
            return roundedLayer.roundedCorners
        }
        set {
            roundedLayer.roundedCorners = newValue
        }
    }

    var roundedLayer: ContinuousMaskLayer {
        return layer as! ContinuousMaskLayer
    }

}
