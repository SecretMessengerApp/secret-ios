
import UIKit

extension UIAlertAction {
    
    static func cancel(_ completion: Completion? = nil) -> UIAlertAction {
        UIAlertAction(
            title: "general.cancel".localized,
            style: .cancel,
            handler: { _ in completion?() }
        )
    }

    static func confirm(style: Style = .cancel, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        UIAlertAction(
            title: "general.confirm".localized,
            style: style,
            handler: handler
        )
    }

    convenience init(icon: StyleKitIcon?, title: String, tintColor: UIColor, handler: ((UIAlertAction) -> Void)? = nil) {
        self.init(title: title, style: .default, handler: handler)

        setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

        if let icon = icon {
            let image = UIImage.imageForIcon(icon, size: 24, color: tintColor)
            setValue(image.withRenderingMode(.alwaysOriginal), forKey: "image")
        }
    }
}
