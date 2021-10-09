
import Foundation
import WireDataModel

fileprivate extension Availability {
    
    var dontRemindMeUserDefaultsKey: String {
        return "dont_remind_me_\(canonicalName)"
    }
    
}

extension Settings {
    
    func shouldRemindUserWhenChanging(_ availability: Availability) -> Bool {
        return defaults.bool(forKey: availability.dontRemindMeUserDefaultsKey) != true
    }
    
    func dontRemindUserWhenChanging(_ availability: Availability) {
        defaults.set(true, forKey: availability.dontRemindMeUserDefaultsKey)
    }
    
}
