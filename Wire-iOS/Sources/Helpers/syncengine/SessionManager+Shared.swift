
import Foundation
import AVFoundation

extension SessionManager {
    static var shared : SessionManager? {
        return AppDelegate.shared.sessionManager
    }
    
    func updateCallNotificationStyleFromSettings() {
        let isCallKitEnabled: Bool = !(Settings.shared[.disableCallKit] ?? false)
//        let hasAudioPermissions = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == AVAuthorizationStatus.authorized
        let isCallKitSupported = !UIDevice.isSimulator
        var isiOSAppOnMac = false
        if #available(iOS 14.0, *) {
            isiOSAppOnMac = ProcessInfo.processInfo.isiOSAppOnMac
        }
        if isCallKitEnabled && isCallKitSupported && !isiOSAppOnMac/* && hasAudioPermissions*/ {
            self.callNotificationStyle = .callKit
        }
        else {
            self.callNotificationStyle = .pushNotifications
        }
    }
}
