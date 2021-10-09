
import Foundation

// This protocol is used for UI (& testing) purposes only.
// In case you'll create a class compliant with this protocol, that returns `true`
// to all the variables specified, you simply won't see the "Wire needs access to..."
// messages, but only empty cells. You won't get any data until the user gives
// his permission via the iOS standard dialog.

public protocol PhotoPermissionsController {
    var isCameraAuthorized: Bool { get }
    var isPhotoLibraryAuthorized: Bool { get }
    var areCameraOrPhotoLibraryAuthorized: Bool { get }
    var areCameraAndPhotoLibraryAuthorized: Bool { get }
}
