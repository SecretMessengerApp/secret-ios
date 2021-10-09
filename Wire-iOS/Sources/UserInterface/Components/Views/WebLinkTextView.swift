
import UIKit


// This subclass is used for the legal text in the Welcome screen and the reset password text in the login screen
// Purpose of this class is to reduce the amount of duplicate code to set the default properties of this NSTextView. On the Mac client we are using something similar to also stop the user from being able to select the text (selection property needs to be enabled to make the NSLinkAttribute work on the string). We may want to add this in the future here as well
final class WebLinkTextView: UITextView {

    init() {
        super.init(frame: .zero, textContainer: nil)

        if #available(iOS 11.0, *) {
            textDragDelegate = self
        }

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        isSelectable = true
        isEditable = false
        isScrollEnabled = false
        bounces = false
        backgroundColor = UIColor.clear
        textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textContainer.lineFragmentPadding = 0
    }


    /// non-selectable textview
    override var selectedTextRange: UITextRange? {
        get { return nil }
        set { /* no-op */ }
    }

    // Prevent double-tap to select 
    override var canBecomeFirstResponder: Bool {
        return false
    }

    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        //Prevent long press to show the magnifying glass
        if gestureRecognizer is UILongPressGestureRecognizer {
            gestureRecognizer.isEnabled = false
        }

        super.addGestureRecognizer(gestureRecognizer)
    }
}


@available(iOS 11.0, *)
extension WebLinkTextView: UITextDragDelegate {

    public func textDraggableView(_ textDraggableView: UIView & UITextDraggable, itemsForDrag dragRequest: UITextDragRequest) -> [UIDragItem] {
        return []
    }

}
