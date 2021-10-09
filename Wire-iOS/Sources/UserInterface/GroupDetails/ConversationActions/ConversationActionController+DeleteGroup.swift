
import Foundation

extension ConversationActionController {
    
    func requestDeleteGroupResult(completion: @escaping (Bool) -> Void) {
        let alertController = UIAlertController.confirmController(
            title: "conversation.delete_request_dialog.title".localized,
            message: "conversation.delete_request_dialog.message".localized,
            confirmTitle: "conversation.delete_request_error_dialog.button_delete_group".localized,
            completion: completion
        )
        present(alertController)
    }
    
    func handleDeleteGroupResult(_ result: Bool, conversation: ZMConversation, in userSession: ZMUserSession) {
        guard result else { return }
        
        transitionToListAndEnqueue {
            conversation.delete(in: userSession) { (result) in
                switch result {
                case .success:
                    break
                case .failure(_):
                    let alert = UIAlertController.alertWithOKButton(title: "error.conversation.title".localized,
                                                                    message: "conversation.delete_request_error_dialog.title".localized(args: conversation.displayName))
                    UIApplication.shared.topmostViewController(onlyFullScreen: false)?.present(alert, animated: true)
                }
            }
        }
    }
}
