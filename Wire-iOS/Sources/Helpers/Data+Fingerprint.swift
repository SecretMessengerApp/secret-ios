

import Foundation

extension Data {
    /// return a lower case and space between every byte string of the given data
    var fingerprintString: String {
        let string = String(decoding: self, as: UTF8.self)

        return string.fingerprintStringWithSpaces
    }

    public func attributedFingerprint(attributes: [NSAttributedString.Key : AnyObject], boldAttributes: [NSAttributedString.Key : AnyObject], uppercase: Bool = false) -> NSAttributedString? {

        var fingerprintString = self.fingerprintString

        if uppercase {
            fingerprintString = fingerprintString.uppercased()
        }

        let attributedRemoteIdentifier = fingerprintString.fingerprintString(attributes: attributes, boldAttributes: boldAttributes)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        return attributedRemoteIdentifier && [.paragraphStyle: paragraphStyle]
    }
}
