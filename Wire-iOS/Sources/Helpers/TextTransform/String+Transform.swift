
import Foundation

extension String {

    /// Creates a new string by applying the given transform.
    ///
    /// - Parameter transform: TextTransform to apply
    /// - Returns: the transformed string
    func applying(transform: TextTransform) -> String {
        switch transform {
        case .none: return self
        case .capitalize: return localizedCapitalized
        case .lower: return localizedLowercase
        case .upper: return localizedUppercase
        }
    }
}

extension NSAttributedString {

    /**
     * Creates a new string by applying the given transform.
     */

    func applying(transform: TextTransform) -> NSAttributedString {
        let newString = string.applying(transform: transform)

        let mutableCopy = self.mutableCopy() as! NSMutableAttributedString
        mutableCopy.replaceCharacters(in: NSRange(location: 0, length: length), with: newString)
        return mutableCopy
    }
}


extension String {
    
    func trim() -> String {
        trimmingCharacters(in: .whitespaces)
    }
}
