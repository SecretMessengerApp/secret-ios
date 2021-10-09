
import Foundation
import WireTransport

extension BackendEnvironment {
    
    public static let backendSwitchNotification = Notification.Name("backendEnvironmentSwitchNotification")
    
    public static var shared: BackendEnvironment = {
        let bundle = Bundle.backendBundle
        guard let environment = BackendEnvironment(userDefaults: .applicationGroup, configurationBundle: .backendBundle) else { fatalError("Malformed backend configuration data") }
        return environment
        }() {
        didSet {
            shared.save(in: .standard)
            NotificationCenter.default.post(name: backendSwitchNotification, object: shared)
        }
    }
}
