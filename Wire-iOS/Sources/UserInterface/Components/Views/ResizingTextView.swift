
import UIKit

class ResizingTextView: TextView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        get {
            return sizeThatFits(CGSize(width: bounds.size.width, height: UIView.noIntrinsicMetric))
        }
    }

    override func paste(_ sender: Any?) {
        super.paste(sender)

        // Work-around for text view scrolling too far when pasting text smaller
        // than the maximum height of the text view.
        setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
}
