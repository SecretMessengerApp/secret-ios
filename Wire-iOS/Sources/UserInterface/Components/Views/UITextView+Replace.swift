
import Foundation

extension UITextView {
    func replace(_ range: NSRange, withAttributedText replacement: NSAttributedString) {
        let updatedString = NSMutableAttributedString(attributedString: attributedText)
        updatedString.replaceCharacters(in: range, with: replacement)

        let selectionOffset = range.location + replacement.length
        attributedText = updatedString

        guard let cursorPosition = position(from: beginningOfDocument, offset:
            selectionOffset) else { return }
        guard let updatedSelection = textRange(from: cursorPosition, to: cursorPosition) else { return }
        selectedTextRange = updatedSelection
    }
}
