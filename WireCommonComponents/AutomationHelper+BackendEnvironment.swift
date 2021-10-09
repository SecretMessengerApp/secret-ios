
import Foundation
import WireTransport

extension AutomationHelper {
    private static let backendEnvironmentTypeOverrideKey = "BackendEnvironmentTypeOverrideKey"
    
    public func backendEnvironmentTypeOverride() -> String? {
        return UserDefaults.applicationGroupCombinedWithStandard.string(forKey: AutomationHelper.backendEnvironmentTypeOverrideKey)
    }
    
    public func persistBackendTypeOverrideIfNeeded(with type: String?) {
        guard shouldPersistBackendType else { return }
        UserDefaults.applicationGroup.set(type, forKey: AutomationHelper.backendEnvironmentTypeOverrideKey)
    }
    
    public func disableBackendTypeOverride() {
        UserDefaults.applicationGroup.removeObject(forKey: AutomationHelper.backendEnvironmentTypeOverrideKey)
    }
    
    public func persistBackendTypeToGroup() {
        guard let value = UserDefaults.standard.string(forKey: EnvironmentType.defaultsKey) else {
            return
        }
        UserDefaults.applicationGroup.set(value, forKey: EnvironmentType.defaultsKey)
    }
    
    public func persistApplicationIdentifier() {
        UserDefaults.standard.set(Bundle.main.applicationGroupIdentifier, forKey: EnvironmentType.groupIdentifier)
    }
}
