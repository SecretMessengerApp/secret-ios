
import Foundation

extension UserDefaults {
    
    public static var applicationGroup: UserDefaults {
        let applicationGroupIdentifier = Bundle.main.applicationGroupIdentifier
        return UserDefaults(suiteName: applicationGroupIdentifier) ?? .standard
    }
    
    public static var applicationGroupCombinedWithStandard: UserDefaults {
        let userDefaults = UserDefaults.standard
        
        if let applicationGroupIdentifier = Bundle.main.applicationGroupIdentifier {
            userDefaults.addSuite(named: applicationGroupIdentifier)
        }
        
        return userDefaults
    }
    
}
