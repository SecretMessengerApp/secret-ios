
import UIKit

/**
 * The dimension to use when calculating relative radii.
 */

enum MaskDimension: Int {
    case width, height
}

/**
 * The shape of a layer mask.
 */

enum MaskShape {
    case circle
    case rectangle
    case relative(multiplier: CGFloat, dimension: MaskDimension)
    case rounded(radius: CGFloat)
}

/**
 * A layer whose corners are rounded with a continuous mask (“squircle“).
 */

class ContinuousMaskLayer: CALayer {

    override var cornerRadius: CGFloat {
        get {
            return 0
        }
        set {
            preconditionFailure("The layer is a `ContinuousMaskLayer`. The `cornerRadius` property is unavailable. Set the `shape` property.")
        }
    }

    var shape: MaskShape = .rectangle {
        didSet {
            refreshMask()
        }
    }

    var roundedCorners: UIRectCorner = .allCorners {
        didSet {
            refreshMask()
        }
    }

    // MARK: - Initialization

    override init(layer: Any) {
        super.init(layer: layer)
        
        if let otherMaskLayer = layer as? ContinuousMaskLayer {
            self.shape = otherMaskLayer.shape
            self.roundedCorners = otherMaskLayer.roundedCorners
        }
        else {
            fatal("Cannot init with \(layer)")
        }
    }

    override init() {
        super.init()
        self.mask = CAShapeLayer()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSublayers() {
        super.layoutSublayers()
        refreshMask()
    }

    private func refreshMask() {

        guard let mask = mask as? CAShapeLayer else {
            return
        }

        let roundedPath: UIBezierPath

        switch shape {
        case .rectangle:
            roundedPath = UIBezierPath(rect: bounds)

        case .circle:
            roundedPath = UIBezierPath(ovalIn: bounds)

        case .rounded(let radius):
            roundedPath = roundedPathForBounds(radius: radius)

        case .relative(let multiplier, let dimension):

            let base: CGFloat

            switch dimension {
            case .width: base = bounds.width
            case .height: base = bounds.height
            }

            roundedPath = roundedPathForBounds(radius: base * multiplier)
        }

        mask.path = roundedPath.cgPath

    }

    private func roundedPathForBounds(radius: CGFloat) -> UIBezierPath {
        let radii = CGSize(width: radius, height: radius)
        return UIBezierPath(roundedRect: bounds, byRoundingCorners: roundedCorners, cornerRadii: radii)
    }

}
