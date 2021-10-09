
import Foundation

extension UITraitEnvironment {
    var isHorizontalSizeClassRegular: Bool {
        return traitCollection.horizontalSizeClass == .regular
    }

    func isIPadRegular(device: DeviceProtocol = UIDevice.current) -> Bool {
        return device.userInterfaceIdiom == .pad && isHorizontalSizeClassRegular
    }

    func isIPadRegularPortrait(device: DeviceProtocol = UIDevice.current, application: ApplicationProtocol = UIApplication.shared) -> Bool {
        return isIPadRegular(device: device) && application.statusBarOrientation.isPortrait
    }
}
