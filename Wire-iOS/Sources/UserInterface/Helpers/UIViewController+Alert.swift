
import Foundation
private let zmLog = ZMSLog(tag: "Alert")

extension UIAlertController {
        
    /// Create an alert with a OK button
    ///
    /// - Parameters:
    ///   - title: optional title of the alert
    ///   - message: message of the alert
    ///   - okActionHandler: a nullable closure for the OK button
    /// - Returns: the alert presented
    static func alertWithOKButton(title: String? = nil,
                                  message: String,
                                  okActionHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        let okAction =  UIAlertAction.ok(style: .cancel, handler: okActionHandler)
        alert.addAction(okAction)

        return alert
    }
    
    static func alertWithOKCancelButton(
        title: String? = nil,
        message: String,
        okActionHandler: ((UIAlertAction) -> Void)? = nil,
        cancelActionHandler: (() -> Void)? = nil
        ) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction.ok(style: .default, handler: okActionHandler)
        let cancelAction = UIAlertAction.cancel(cancelActionHandler)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        return alert
    }

}

extension UIViewController {
    
    /// Present an alert with a OK button
    ///
    /// - Parameters:
    ///   - title: optional title of the alert
    ///   - message: message of the alert
    ///   - animated: present the alert animated or not
    ///   - okActionHandler: optional closure for the OK button
    /// - Returns: the alert presented
    @discardableResult
    func presentAlertWithOKButton(title: String? = nil,
                                  message: String,
                                  animated: Bool = true,
                                  okActionHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {

        let alert = UIAlertController.alertWithOKButton(title: title,
                                         message: message,
                                         okActionHandler: okActionHandler)

        present(alert, animated: animated, completion: nil)

        return alert
    }
    
    @discardableResult
    func presentAlertWithOKCancelButton(
        title: String? = nil,
        message: String,
        animated: Bool = true,
        okActionHandler: ((UIAlertAction) -> Void)? = nil,
        cancelActionHandler: (() -> Void)? = nil
        ) -> UIAlertController {
        
        let alert = UIAlertController.alertWithOKCancelButton(
            title: title,
            message: message,
            okActionHandler: okActionHandler,
            cancelActionHandler: cancelActionHandler
        )
        
        present(alert, animated: animated, completion: nil)
        
        return alert
    }

    // MARK: - user profile deep link

    @discardableResult
    func presentInvalidUserProfileLinkAlert(okActionHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        return presentAlertWithOKButton(title: "url_action.invalid_user.title".localized,
                                        message: "url_action.invalid_user.message".localized,
                                        okActionHandler: okActionHandler)
    }
    
}
