
import UIKit

extension UIDevice {

    @objc static var isSimulator: Bool {
        #if (arch(i386) || arch(x86_64))
            return true
        #else
            return false
        #endif
    }

}
