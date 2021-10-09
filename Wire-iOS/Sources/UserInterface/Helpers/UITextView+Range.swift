
import Foundation
extension UITextView {
    
    @objc(rangeOfLinkToURL:)
    func rangeOfLink(to url: NSURL) -> UITextRange? {
        var foundRange: NSRange = NSRange(location: NSNotFound, length: 0)
        
        attributedText.enumerateAttribute(.link,
                                          in: NSRange(location: 0, length: attributedText.length),
                                          options: []) { (value, range, stop) in
                                            if url.isEqual(value) {
                                                stop.pointee = true
                                                foundRange = range
                                            }
        }
        
        guard foundRange.location != NSNotFound,
              let startPosition = position(from: beginningOfDocument, offset: foundRange.location),
              let endPosition = position(from: beginningOfDocument, offset: foundRange.location + foundRange.length) else {
            return nil
        }
        
        return textRange(from: startPosition, to: endPosition)
    }
}
