
import Foundation

protocol CallPermissionsConfiguration {
    var canAcceptAudioCalls: Bool { get }
    var isPendingAudioPermissionRequest: Bool { get }

    var canAcceptVideoCalls: Bool { get }
    var isPendingVideoPermissionRequest: Bool { get }

    func requestVideoPermissionWithoutWarning(resultHandler: @escaping (Bool) -> Void)
    func requestOrWarnAboutVideoPermission(resultHandler: @escaping (Bool) -> Void)
    func requestOrWarnAboutAudioPermission(resultHandler: @escaping (Bool) -> Void)
}

extension CallPermissionsConfiguration {

    var isAudioDisabledForever: Bool {
        return canAcceptAudioCalls == false && isPendingAudioPermissionRequest == false
    }

    var isVideoDisabledForever: Bool {
        return canAcceptVideoCalls == false && isPendingVideoPermissionRequest == false
    }

    var preferredVideoPlaceholderState: CallVideoPlaceholderState {
        guard !canAcceptVideoCalls else { return .hidden }
        return isPendingVideoPermissionRequest ? .statusTextHidden : .statusTextDisplayed
    }

}

func ==(lhs: CallPermissionsConfiguration, rhs: CallPermissionsConfiguration) -> Bool {
    return lhs.canAcceptAudioCalls == rhs.canAcceptAudioCalls &&
           lhs.isPendingAudioPermissionRequest == rhs.isPendingAudioPermissionRequest &&
           lhs.canAcceptVideoCalls == rhs.canAcceptVideoCalls &&
           lhs.isPendingVideoPermissionRequest == rhs.isPendingVideoPermissionRequest
}
