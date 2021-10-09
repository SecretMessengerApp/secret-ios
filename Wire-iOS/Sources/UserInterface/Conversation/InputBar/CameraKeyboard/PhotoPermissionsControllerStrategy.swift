
import Foundation
import Photos


final class PhotoPermissionsControllerStrategy: PhotoPermissionsController {

    // `unauthorized` state happens the first time before opening the keyboard,
    // so we don't need to check it for our purposes.

    var isCameraAuthorized: Bool {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized: return true
        default: return false
        }
    }

    var isPhotoLibraryAuthorized: Bool {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized: return true
        default: return false
        }
    }

    var areCameraOrPhotoLibraryAuthorized: Bool {
        return isCameraAuthorized || isPhotoLibraryAuthorized
    }

    var areCameraAndPhotoLibraryAuthorized: Bool {
        return isCameraAuthorized && isPhotoLibraryAuthorized
    }
}
