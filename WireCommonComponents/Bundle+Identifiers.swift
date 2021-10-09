//
import Foundation

extension Bundle {
    public var applicationGroupIdentifier: String? {
        return infoDictionary?["ApplicationGroupIdentifier"] as? String
    }
    
    public var hostBundleIdentifier: String? {
        return infoDictionary?["HostBundleIdentifier"] as? String
    }
}
