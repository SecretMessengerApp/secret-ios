
import Foundation
import UIKit

extension UITextView {
    // Autocorrects the last word, if necessary.
    func autocorrectLastWord() {
        UIView.performWithoutAnimation {
            resignFirstResponder()
            becomeFirstResponder()
        }
    }
}
