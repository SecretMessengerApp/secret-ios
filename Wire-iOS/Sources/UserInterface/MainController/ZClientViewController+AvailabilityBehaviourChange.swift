
import Foundation

extension ZClientViewController {
    
    func showAvailabilityBehaviourChangeAlertIfNeeded() {
        
        guard var notify = ZMUser.selfUser()?.needsToNotifyAvailabilityBehaviourChange, notify.contains(.alert),
              let availability = ZMUser.selfUser()?.availability else { return }
                
        present(UIAlertController.availabilityExplanation(availability), animated: true)
        
        ZMUserSession.shared()?.performChanges {
            notify.remove(.alert)
            ZMUser.selfUser()?.needsToNotifyAvailabilityBehaviourChange = notify
        }
    }
    
}
