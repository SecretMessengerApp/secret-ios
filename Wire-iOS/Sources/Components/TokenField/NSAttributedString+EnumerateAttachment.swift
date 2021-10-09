
import Foundation

extension NSAttributedString {
    func enumerateAttachment(block: (Any?, NSRange, UnsafeMutablePointer<ObjCBool>) -> Void) {
        return enumerateAttachment(range: NSRange(location: 0, length: length), block: block)
    }

    func enumerateAttachment(range: NSRange,
                             block: (Any?, NSRange, UnsafeMutablePointer<ObjCBool>) -> Void) {
        enumerateAttribute(.attachment, in: range, options: [], using: block)
    }
}
