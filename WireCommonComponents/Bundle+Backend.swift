
import Foundation

extension Bundle {
    public static var backendBundle: Bundle {
        guard let backendBundlePath = Bundle.appMainBundle.path(forResource: "Backend", ofType: "bundle") else { fatalError("Could not find backend.bundle") }
        guard let bundle = Bundle(path: backendBundlePath) else { fatalError("Could not load backend.bundle") }
        return bundle
    }
}
