

import UIKit


/// A derative of UIView whose main body is completely invisible to touches so they are passed through to whatever is below, yet its subviews and subsubviews in designated classes still process the touches.
final class PassthroughTouchesView: UIView {
    override var isOpaque: Bool {
        get {
            return false
        }

        set {
            //no-op
        }
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard bounds.contains(point) else {
            return false
        }

        for subview in subviews {

            // Don’t consider hidden subviews in hit testing
            if subview.isHidden || subview.alpha == 0 {
                continue
            }

            let translatedPoint = convert(point, to: subview)
            if subview.point(inside: translatedPoint, with: event) {
                return true
            }

            // 1st level subviews did not match, so iterate through 2nd level

            for subSubview in subview.subviews {
                let translatedSubSubPoint = convert(point, to: subSubview)
                if subview.point(inside: translatedPoint, with: event) && subSubview.point(inside: translatedSubSubPoint, with: event) {
                    return true
                }
            }
        }

        return false
    }
}
