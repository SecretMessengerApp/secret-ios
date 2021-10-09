
import Foundation
import AVFoundation

class CallPermissions: CallPermissionsConfiguration {

    var isPendingAudioPermissionRequest: Bool {
        if UIDevice.isSimulator {
            // on iOS simulator microphone permissions are always granted by default
            return false
        }
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .notDetermined
    }

    var isPendingVideoPermissionRequest: Bool {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .notDetermined
    }

    var canAcceptAudioCalls: Bool {
        if UIDevice.isSimulator {
            // on iOS simulator, microphone permissions are granted by default, but AVCaptureDevice does not
            // return the correct status
            return true
        }
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .authorized
    }

    var canAcceptVideoCalls: Bool {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
    }

    func requestVideoPermissionWithoutWarning(resultHandler: @escaping (Bool) -> Void) {
        UIApplication.wr_requestVideoAccess(resultHandler)
    }

    func requestOrWarnAboutAudioPermission(resultHandler: @escaping (Bool) -> Void) {
        if UIDevice.isSimulator {
            // on iOS simulator microphone permissions are always granted by default
            resultHandler(true)
            return
        }
        UIApplication.wr_requestOrWarnAboutMicrophoneAccess(resultHandler)
    }

    func requestOrWarnAboutVideoPermission(resultHandler: @escaping (Bool) -> Void) {
        UIApplication.wr_requestOrWarnAboutVideoAccess(resultHandler)
    }

}
