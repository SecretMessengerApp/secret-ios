
import UIKit

extension UIAlertController {
    
    static func checkYourConnection() -> UIAlertController {
        let controller = UIAlertController(
            title: "guest_room.error.generic.title".localized,
            message: "guest_room.error.generic.message".localized,
            preferredStyle: .alert
        )
        controller.addAction(.ok())
        controller.view.tintColor = UIColor.dynamic(scheme: .title)
        return controller
    }
    
    static func confirmRemovingGuests(_ completion: @escaping (Bool) -> Void) -> UIAlertController {
        return confirmController(
            title: "guest_room.remove_guests.message".localized,
            confirmTitle: "guest_room.remove_guests.action".localized,
            completion: completion
        )
    }
    
    static func confirmRevokingLink(_ completion: @escaping (Bool) -> Void) -> UIAlertController {
        return confirmController(
            title: "guest_room.revoke_link.message".localized,
            confirmTitle: "guest_room.revoke_link.action".localized,
            completion: completion
        )
    }
    
    static func confirmController(title: String,
                                  message: String? = nil,
                                  confirmAction: UIAlertAction,
                                  completion: @escaping (Bool) -> Void) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

        controller.addAction(confirmAction)
        controller.addAction(.cancel { completion(false) })
        controller.view.tintColor = UIColor.dynamic(scheme: .title)
        return controller
    }

    static func confirmController(title: String,
                                  message: String? = nil,
                                  confirmTitle: String,
                                  completion: @escaping (Bool) -> Void) -> UIAlertController {
        let confirmAction = UIAlertAction(title: confirmTitle, style: .destructive) { _ in
            completion(true)
        }

        return UIAlertController.confirmController(title: title,
                                                   message: message,
                                                   confirmAction: confirmAction,
                                                   completion: completion)
    }
}
