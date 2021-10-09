
import Foundation

extension UIAccessibilityIdentification where Self: NSObject {

    /// set accessibility identifier and accessibility label to an interaction enabled UI widget.
    func setLegalHoldAccessibility() {
        accessibilityIdentifier = "legalhold"
        accessibilityLabel = "legalhold.accessibility".localized
    }
}
