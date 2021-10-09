
import Foundation

extension UIViewController {

    // update the popover's frame if this UIViewController is presented from a PopoverPresenter.
    // This method should be called when PopoverPresenter's frame size changes or its popover related content is updated.
    func updatePopoverFrame() {
        if let popoverPresenter = popoverPresentationController?.presentingViewController as? PopoverPresenter {
            popoverPresenter.updatePopoverSourceRect()
        }

        popoverPresentationController?.containerView?.setNeedsLayout()
    }

    func endEditing() {
        view.window?.endEditing(true)
    }
}
