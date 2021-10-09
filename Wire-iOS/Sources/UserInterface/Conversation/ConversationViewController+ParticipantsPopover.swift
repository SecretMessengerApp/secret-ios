
import UIKit

extension ConversationViewController: UIPopoverPresentationControllerDelegate {

    func createAndPresentParticipantsPopoverController(
        with rect: CGRect,
        from view: UIView,
        contentViewController controller: UIViewController
    ) {

        endEditing()

        controller.presentationController?.delegate = self
        present(controller, animated: true)
    }
}

extension ConversationViewController: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        if controller.presentedViewController is AddParticipantsViewController {
            return .overFullScreen
        }
        if #available(iOS 13, *) {
            return .formSheet
        } else {
            return .fullScreen
        }
    }
}

extension ConversationViewController: ViewControllerDismisser {
    func dismiss(viewController: UIViewController, completion: (() -> ())?) {
        dismiss(animated: true, completion: completion)
    }
}
