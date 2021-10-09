// 

import UIKit

final class RequestPasswordController {
    
    typealias Callback = (_ password: String?) -> ()
    
    enum RequestPasswordContext {
        case removeDevice
        case logout
    }
    
    var alertController: UIAlertController
    
    private let callback: Callback
    private weak var okAction: UIAlertAction?
    internal weak var passwordTextField: UITextField?

    deinit {
        debugPrint("textField--")
    }
    
    init(context: RequestPasswordContext, callback: @escaping Callback) {

        self.callback = callback
        
        let okTitle: String = "general.ok".localized
        let cancelTitle: String = "general.cancel".localized
        let title: String
        let message: String
        let placeholder: String

        switch context {
        case .removeDevice:
            title = "self.settings.account_details.remove_device.title".localized
            message = "self.settings.account_details.remove_device.message".localized
            placeholder = "self.settings.account_details.remove_device.password".localized
            
        case .logout:
            title = "self.settings.account_details.log_out.alert.title".localized
            message = "self.settings.account_details.log_out.alert.message".localized
            placeholder = "self.settings.account_details.log_out.alert.password".localized
        }

        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = placeholder
            textField.isSecureTextEntry = true
            if #available(iOS 11.0, *) {
                textField.textContentType = .password
            }
            textField.addTarget(self, action: #selector(RequestPasswordController.passwordTextFieldChanged(_:)), for: .editingChanged)
            
            self.passwordTextField = textField
        }

        let okAction = UIAlertAction(title: okTitle, style: .destructive) { [weak self] action in
            if let passwordField = self?.alertController.textFields?[0] {
                self?.callback(passwordField.text)
            }
        }

        okAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { [weak self] action in
            self?.callback(nil)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        alertController.preferredAction = okAction

        self.okAction = okAction
    }

    @objc
    func passwordTextFieldChanged(_ textField: UITextField) {
        guard let passwordField = alertController.textFields?[0] else { return }

        okAction?.isEnabled = passwordField.text?.isEmpty == false
    }
}
