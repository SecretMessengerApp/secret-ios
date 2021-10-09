
import Foundation

extension UIView {
    func popoverSourceRect(from viewController: UIViewController) -> CGRect {
        let sourceView: UIView = viewController.parent?.view ?? viewController.view

        // We want point to text of the textView instead of the oversized frame
        var popoverSourceRect: CGRect
        if self is UITextView {
            popoverSourceRect = sourceView.convert(CGRect(origin: frame.origin, size: intrinsicContentSize), from: superview)
        } else {
            popoverSourceRect = sourceView.convert(frame, from: superview)
        }

        // if the converted rect is out of bound, clamp origin to (0,0)
        // (provide a negative value to UIPopoverPresentationController.sourceRect may have no effect)
        let clampedOrigin = CGPoint(x: fmax(0, popoverSourceRect.origin.x), y: fmax(0, popoverSourceRect.origin.y))
        popoverSourceRect = CGRect(origin: clampedOrigin, size: popoverSourceRect.size)

        return popoverSourceRect
    }
}
