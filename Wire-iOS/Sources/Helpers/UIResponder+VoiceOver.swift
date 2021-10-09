
import Foundation

extension UIResponder {

    /**
     * Makes the responder become the first responder if VoiceOver is not running,
     * to allow screenreader users to discover the contents of the screen before
     * prompting for input.
     * - returns: Whether the object became the first responder.
     */

    @discardableResult
    func becomeFirstResponderIfPossible() -> Bool {
        guard !UIAccessibility.isVoiceOverRunning else {
            return false
        }

        return becomeFirstResponder()
    }

}
