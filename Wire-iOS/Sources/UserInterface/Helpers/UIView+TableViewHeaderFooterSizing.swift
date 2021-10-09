
import UIKit

extension UIView {
    func size(fittingWidth width: CGFloat) {
        frame.size = systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.noIntrinsicMetric),
            withHorizontalFittingPriority: UILayoutPriority.required,
            verticalFittingPriority: UILayoutPriority.fittingSizeLevel
        )
    }
}
