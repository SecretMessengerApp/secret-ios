
import Foundation

extension UIAlertController {
    
    static func availabilityExplanation(_ availability: Availability) -> UIAlertController {
        
        let title = "availability.reminder.\(availability.canonicalName).title".localized
        let message = "availability.reminder.\(availability.canonicalName).message".localized
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "availability.reminder.action.dont_remind_me".localized, style: .default, handler: { (_) in
            Settings.shared.dontRemindUserWhenChanging(availability)
        }))
        alert.addAction(UIAlertAction(title: "availability.reminder.action.ok".localized, style: .default, handler: { (_) in }))
        
        return alert
    }
    
    static func availabilityPicker(_ handler: @escaping (_ availability: Availability) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "availability.message.set_status".localized, message: nil, preferredStyle: .actionSheet)
        
        for availability in Availability.allCases {
            alert.addAction(UIAlertAction(title: availability.localizedName, style: .default, handler: { _ in
                handler(availability)
            }))
        }
        
        alert.popoverPresentationController?.permittedArrowDirections = [ .up ]
        alert.addAction(UIAlertAction(title: "availability.message.cancel".localized, style: .cancel, handler: nil))
        alert.applyTheme()
        return alert
    }
}
