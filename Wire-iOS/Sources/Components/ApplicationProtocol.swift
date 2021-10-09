
import Foundation

protocol ApplicationProtocol {
    var statusBarOrientation: UIInterfaceOrientation { get }
    var applicationState: UIApplication.State { get }

    static func wr_requestOrWarnAboutPhotoLibraryAccess(_ grantedHandler: ((Bool) -> Swift.Void)!)
}

extension UIApplication: ApplicationProtocol {}
