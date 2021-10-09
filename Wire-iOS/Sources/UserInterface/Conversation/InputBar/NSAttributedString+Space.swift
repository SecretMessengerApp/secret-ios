
import Foundation

extension NSAttributedString {
    func hasSpaceAt(position: Int) -> Bool {
        let scalars = attributedSubstring(from: NSRange(location: position, length: 1)).string.unicodeScalars
        let justSpaces = scalars.filter(NSCharacterSet.whitespacesAndNewlines.contains)
        return !justSpaces.isEmpty
    }
}
