
import Foundation

protocol DeviceProtocol {
    var userInterfaceIdiom: UIUserInterfaceIdiom { get }
    var orientation: UIDeviceOrientation { get }
}

extension UIDevice: DeviceProtocol {}

extension UIDevice {
    enum `Type` {
        case iPhone, iPod, iPad, unspecified
    }
    
    var type: `Type` {
        if model.contains("iPod") { return .iPod }
        if userInterfaceIdiom == .phone { return .iPhone }
        if userInterfaceIdiom == .pad { return .iPad }
        return .unspecified
    }
}
