

import Foundation


extension AutomationHelper {
    
    static let ApplicationActiveStatusKey = "ApplicationActiveStatusKey"
    
    public func persistBecomeActiveStatusToGroup() {
        UserDefaults.applicationGroup.set(true, forKey: AutomationHelper.ApplicationActiveStatusKey)
        UserDefaults.applicationGroup.synchronize()
    }
    
    public func persistResignActiveStatusToGroup() {
        UserDefaults.applicationGroup.set(false, forKey: AutomationHelper.ApplicationActiveStatusKey)
        UserDefaults.applicationGroup.synchronize()
    }
    
    public func isActive() -> Bool {
        return UserDefaults.applicationGroup.bool(forKey: AutomationHelper.ApplicationActiveStatusKey)
    }
    
}
