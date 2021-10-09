
import UIKit

public typealias AlertActionHandler = (UIAlertAction) -> Void

public extension UIAlertController {

    /// Create an alert with a OK button
    ///
    /// - Parameters:
    ///   - title: optional title of the alert
    ///   - message: message of the alert
    ///   - okActionHandler: a nullable closure for the OK button
    /// - Returns: the alert presented
    static func alertWithOKButton(title: String? = nil,
                                  message: String,
                                  okActionHandler: AlertActionHandler? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        let okAction =  UIAlertAction.ok(style: .cancel, handler: okActionHandler)
        alert.addAction(okAction)

        return alert
    }

    convenience init(title: String? = nil,
                     message: String,
                     alertAction: UIAlertAction) {
        self.init(title: title,
                  message: message,
                  preferredStyle: .alert)
        addAction(alertAction)
    }

}

public extension UIAlertAction {
    static func ok(_ completion: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction.ok(style: .default, handler: completion)
    }

    static func ok(style: Style = .default, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(
            title: "general.ok".localized,
            style: style,
            handler: handler
        )
    }
}
