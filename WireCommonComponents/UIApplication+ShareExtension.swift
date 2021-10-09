
import UIKit

extension UIApplication {
    static var runningInExtension: Bool {
        return Bundle.main.bundlePath.hasSuffix(".appex")
    }
}
