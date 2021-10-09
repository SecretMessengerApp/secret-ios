

import Foundation
import TTTAttributedLabel


extension TTTAttributedLabel {

    func addLinks() {
        
        attributedText?.enumerateAttribute(.link, in: NSMakeRange(0, attributedText.length), options: [], using: { (value: Any?, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if let URL = value as? URL {
                self.addLink(to: URL, with: range)
            }
        })
        
    }
}

