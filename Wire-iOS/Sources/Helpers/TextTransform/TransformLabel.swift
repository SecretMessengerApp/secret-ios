
import UIKit

/**
 * A label that can automatically transform the text it presents.
 */

final class TransformLabel: UILabel {

    override var accessibilityValue: String? {
        set {
            super.accessibilityValue = newValue
        }
        
        get {
            return attributedText?.string ?? text
        }
    }

    /// The transform to apply to the text.
    var textTransform: TextTransform = .none {
        didSet {
            attributedText = attributedText?.applying(transform: textTransform)
        }
    }

    override var text: String? {
        get {
            return super.text
        }
        set {
            super.text = newValue?.applying(transform: textTransform)
        }
    }

    override var attributedText: NSAttributedString? {
        get {
            return super.attributedText
        }
        set {
            super.attributedText = newValue?.applying(transform: textTransform)
        }
    }

}
