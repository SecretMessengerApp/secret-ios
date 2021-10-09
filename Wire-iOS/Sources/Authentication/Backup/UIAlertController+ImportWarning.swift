
import UIKit

extension UIAlertController {

    static func historyImportWarning(completion: @escaping () -> Void) -> UIAlertController {
        let controller = UIAlertController(
            title: "registration.no_history.restore_backup_warning.title".localized,
            message: "registration.no_history.restore_backup_warning.message".localized,
            alertAction: .cancel()
        )
        
        let proceedAction = UIAlertAction(
            title: "registration.no_history.restore_backup_warning.proceed".localized,
            style: .default,
            handler: { _ in completion() }
        )
        controller.addAction(proceedAction)
        return controller
    }

}
