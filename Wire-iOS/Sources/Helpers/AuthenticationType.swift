
import LocalAuthentication

enum AuthenticationType {
    case touchID, faceID, passcode, unavailable
    
    static var current: AuthenticationType {
        let context = LAContext()
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else { return .unavailable }
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else { return .passcode }
        
        guard #available(iOS 11.0, *) else { return .touchID }
        
        switch context.biometryType {
        case .none: return .passcode
        case .touchID: return .touchID
        case .faceID: return .faceID
        @unknown default:
            return .passcode
        }
    }
}
