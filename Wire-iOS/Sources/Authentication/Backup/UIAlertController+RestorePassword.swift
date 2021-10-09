
import UIKit

extension UIAlertController {
    
    static func requestRestorePassword(completion: @escaping (String?) -> Void) -> UIAlertController {
        let controller = UIAlertController(
            title: "registration.no_history.restore_backup.password.title".localized,
            message: nil,
            preferredStyle: .alert
        )
        
        var token: Any?
        
        func complete(_ result: String?) {
            token.apply(NotificationCenter.default.removeObserver)
            completion(result)
        }
        
        let okAction = UIAlertAction(title: "general.ok".localized, style: .default) { [controller] _ in
            complete(controller.textFields?.first?.text)
        }
        
        okAction.isEnabled = false
    
        controller.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = "registration.no_history.restore_backup.password.placeholder".localized
            token = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { _ in
                okAction.isEnabled = textField.text?.count ?? 0 >= Password.minimumCharacters
            }
        }
    
        controller.addAction(.cancel { complete(nil) })
        controller.addAction(okAction)
        return controller
    }
    
    static func importWrongPasswordError(completion: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let controller = UIAlertController(
            title: "registration.no_history.restore_backup.password_error.title".localized,
            message: nil,
            preferredStyle: .alert
        )
        
        controller.addAction(.ok(completion))
        return controller
    }

}
