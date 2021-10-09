import UIKit

extension UIViewController {

    /// Returns true if the view controller is presented inside a popover
    var isInsidePopover: Bool {
        guard let popoverPresentationController = popoverPresentationController else { return false }

        return popoverPresentationController.arrowDirection != .unknown
    }
}
