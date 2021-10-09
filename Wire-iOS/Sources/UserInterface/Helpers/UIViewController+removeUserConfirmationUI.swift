
import Foundation
import avs

extension UIViewController {

    /// Present an action sheet for user removal confirmation
    /// Notice: if the participant is not in the conversation, the action sheet still shows.
    ///
    /// - Parameters:
    ///   - participant: user to remove
    ///   - conversation: the current converation contains that user
    ///   - viewControllerDismiser: a ViewControllerDismisser to call when this UIViewController is dismissed
    ///   - success:
    func presentRemoveDialogue(
        for participant: ZMUser,
        from conversation: ZMConversation,
        dismisser: ViewControllerDismisser? = nil,
        success: (() -> Void)? = nil
        ) {

        let controller = UIAlertController.remove(participant) { [weak self] remove in
            guard let `self` = self, remove else { return }
 
            conversation.removeOrShowError(participnant: participant) { result in
                switch result {
                case .success:
                    success?()
                    dismisser?.dismiss(viewController: self, completion: nil)
                case .failure(_):
                    break
                }
            }
        }
        
        present(controller, animated: true)
        AVSMediaManager.sharedInstance().mediaManagerPlayAlert()
    }
}
