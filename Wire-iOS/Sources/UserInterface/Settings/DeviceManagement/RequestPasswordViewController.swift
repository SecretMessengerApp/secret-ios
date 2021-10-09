

import Foundation

class RequestPasswordViewController: UIAlertController {
    
    var callback: ((Result<String>) -> ())? = .none
    
    var okAction: UIAlertAction? = .none
    
    static func requestPasswordController(_ callback: @escaping (Result<String>) -> ()) -> RequestPasswordViewController {
        
        let title = NSLocalizedString("self.settings.account_details.remove_device.title", comment: "")
        let message = NSLocalizedString("self.settings.account_details.remove_device.message", comment: "")
        
        let controller = RequestPasswordViewController(title: title, message: message, preferredStyle: .alert)
        controller.callback = callback
        
        controller.addTextField { (textField: UITextField) -> Void in
            textField.placeholder = NSLocalizedString("self.settings.account_details.remove_device.password", comment: "")
            textField.isSecureTextEntry = true
            textField.addTarget(controller, action: #selector(RequestPasswordViewController.passwordTextFieldChanged(_:)), for: .editingChanged)
        }
        
        let okTitle = NSLocalizedString("general.ok", comment: "")
        let cancelTitle = NSLocalizedString("general.cancel", comment: "")
        let okAction = UIAlertAction(title: okTitle, style: .default) { [unowned controller] (action: UIAlertAction) -> Void in
            if let passwordField = controller.textFields?[0] {
                let password = passwordField.text ?? ""
                controller.callback?(.success(password))
            }
        }
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { [unowned controller] (action: UIAlertAction) -> Void in
            controller.callback?(.failure(NSError(domain: "\(type(of: controller))", code: 0, userInfo: [NSLocalizedDescriptionKey: "User cancelled input"])))
        }
        
        okAction.isEnabled = false
        
        controller.okAction = okAction
        
        controller.addAction(okAction)
        controller.addAction(cancelAction)
        
        return controller
    }
    
    @objc func passwordTextFieldChanged(_ textField: UITextField) {
        if let passwordField = self.textFields?[0] {
            self.okAction?.isEnabled = (passwordField.text ?? "").count > 6;
        }
    }
}
