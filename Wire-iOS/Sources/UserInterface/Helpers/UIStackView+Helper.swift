
import UIKit

extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis) {
        self.init(frame: .zero)
        self.axis = axis
    }
    
    var visibleSubviews: [UIView] {
        return subviews.filter { !$0.isHidden }
    }
}
