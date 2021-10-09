
import Foundation

extension AddBotError {
    
    var localizedTitle: String {
        return "peoplepicker.services.add_service.error.title".localized
    }
    
    var localizedMessage: String {
        switch self {
        case .tooManyParticipants:
            return "peoplepicker.services.add_service.error.full".localized
        default:
            return "peoplepicker.services.add_service.error.default".localized
        }
    }
    
    func displayAddBotError(in viewController: UIViewController) {
        let alert = UIAlertController(title: self.localizedTitle,
                                      message: self.localizedMessage,
                                      alertAction: .confirm())
        viewController.present(alert, animated: true, completion: nil)
    }
}
