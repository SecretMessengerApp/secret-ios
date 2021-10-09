
import UIKit

extension String {
    
    func split(every: Int) -> [String] {
        return stride(from: 0, to: count, by: every).map { i in
            let start = index(startIndex, offsetBy: i)
            let end = index(start, offsetBy: every, limitedBy: endIndex) ?? endIndex
            
            return String(self[start..<end])
        }
    }
    
    var fingerprintStringWithSpaces: String {
        return split(every:2).joined(separator: " ")
    }
    
    func fingerprintString(attributes: [NSAttributedString.Key: Any],
                           boldAttributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        var bold = true
        return split{ !$0.isHexDigit }.map {
            let attributedElement = String($0) && (bold ? boldAttributes : attributes)
            
            bold = !bold
            
            return attributedElement
        }.joined(separator: NSAttributedString(string: " "))
    }
}
