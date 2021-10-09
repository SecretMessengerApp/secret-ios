
import Foundation
import Down

extension NSMutableAttributedString {
    
    @objc
    static func markdown(from text: String, style: DownStyle) -> NSMutableAttributedString {
        let down = Down(markdownString: text)
        let result: NSMutableAttributedString
        
        if let attrStr = try? down.toAttributedString(using: style) {
            result = NSMutableAttributedString(attributedString: attrStr)
        } else {
            result = NSMutableAttributedString(string: text)
        }
        
        if result.string.last == "\n" {
            result.deleteCharacters(in: NSMakeRange(result.length - 1, 1))
        }
        
        return result
    }
    
}

extension NSAttributedString {

    /// Trim the NSAttributedString to given number of line limit and add an ellipsis at the end if necessary
    ///
    /// - Parameter numberOfLinesLimit: number of line reserved
    /// - Returns: the trimmed NSAttributedString. If not excess limit, return the original NSAttributedString
    func trimmedToNumberOfLines(numberOfLinesLimit: Int) -> NSAttributedString {
        /// trim the string to first four lines to prevent last line narrower spacing issue
        let lines = string.components(separatedBy: ["\n"])
        if lines.count > numberOfLinesLimit {
            let headLines = lines.prefix(numberOfLinesLimit).joined(separator: "\n")

            return attributedSubstring(from: NSMakeRange(0, headLines.count)) + String.ellipsis
        } else {
            return self
        }
    }
}
