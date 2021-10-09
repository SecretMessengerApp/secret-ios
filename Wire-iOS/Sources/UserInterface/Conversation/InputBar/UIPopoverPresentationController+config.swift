
import Foundation


public protocol PopoverPresenter: class {

    /// The presenting popover. Its frame should be updated when the orientation or screen size changes.
    var presentedPopover: UIPopoverPresentationController? {get set}

    /// The popover's arrow points to this view
    var popoverPointToView: UIView? {get set}


    /// call this method when the presented popover have to update its frame, e.g. when device roated or keyboard toggled
    func updatePopoverSourceRect()
}

extension PopoverPresenter where Self: UIViewController {
    public func updatePopoverSourceRect() {
        guard let presentedPopover = presentedPopover,
              let popoverPointToView = popoverPointToView else { return }

        presentedPopover.sourceRect = popoverPointToView.popoverSourceRect(from: self)
    }
}


extension UIPopoverPresentationController {

    /// Config a UIPopoverPresentationController to let it can update its position correctly after its presenter's frame is updated
    ///
    /// - Parameters:
    ///   - popoverPresenter: the PopoverPresenter which presents this popover
    ///   - pointToView: the view in the presenter the popover's arrow points to
    ///   - sourceView: the view which presents this popover, usually a view of a UIViewController
    func config(from popoverPresenter: PopoverPresenter,
                       pointToView: UIView,
                       sourceView: UIView) {

        if let viewController = popoverPresenter as? UIViewController {
            sourceRect = pointToView.popoverSourceRect(from: viewController)
        }

        popoverPresenter.presentedPopover = self
        popoverPresenter.popoverPointToView = pointToView

        self.sourceView = sourceView
    }
}
