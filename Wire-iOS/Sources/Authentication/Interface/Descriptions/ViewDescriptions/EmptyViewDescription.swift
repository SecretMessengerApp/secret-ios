
import Foundation

/**
 * A view description for an empty view.
 */

final class EmptyViewDescription: NSObject, ValueSubmission, ViewDescriptor {
    var valueSubmitted: ValueSubmitted?
    var valueValidated: ValueValidated?
    var acceptsInput: Bool = true
    var constraints: [NSLayoutConstraint] = []

    func create() -> UIView {
        return UIView()
    }
}
