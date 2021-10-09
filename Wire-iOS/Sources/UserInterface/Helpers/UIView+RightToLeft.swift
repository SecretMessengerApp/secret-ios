
import UIKit

fileprivate extension CGAffineTransform {

    static var verticallyMirrored: CGAffineTransform {
        return CGAffineTransform(scaleX: -1, y: 1)
    }

}

public extension UIView {

    func applyRTLTransformIfNeeded() {
        transform = isRightToLeft ? .verticallyMirrored : .identity
    }

    var isRightToLeft: Bool {
        return UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
    }
    
}
