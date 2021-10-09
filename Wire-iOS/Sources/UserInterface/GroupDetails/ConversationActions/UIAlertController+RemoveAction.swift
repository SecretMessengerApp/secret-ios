
import Foundation


extension UIAlertController {
    static func remove(_ user: ZMUser, completion: @escaping (Bool) -> Void) -> UIAlertController {
        let controller = UIAlertController(
            title: "profile.remove_dialog_message".localized(args: user.displayName),
            message: nil,
            preferredStyle: .actionSheet
        )
        controller.addAction(ZMConversation.Action.remove.alertAction { completion(true) })
        controller.addAction(.cancel { completion(false) })
        controller.applyTheme()
        return controller
    }
}
