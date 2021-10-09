
import UIKit

extension UIEdgeInsets {
    mutating func adjust(top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) {
        top.apply { self.top = $0 }
        left.apply{ self.left = $0 }
        bottom.apply { self.bottom = $0 }
        right.apply { self.right = $0 }
    }
}
