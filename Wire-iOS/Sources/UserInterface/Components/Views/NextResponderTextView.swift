import UIKit

class NextResponderTextView: ResizingTextView {
    
    weak var overrideNextResponder: UIResponder?
    
    override var next: UIResponder? {
        return overrideNextResponder ?? super.next
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return overrideNextResponder != nil ? false : super.canPerformAction(action, withSender: sender)
    }
}
