

import UIKit


extension UITraitEnvironment {
    
    func userInterfaceStyleDidChange(
        _ previousTraitCollection: UITraitCollection?,
        completion: ((Bool) -> Void)? = nil
    ) {
        if #available(iOS 13.0, *) {
            let changed = previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false
            let isDark = traitCollection.userInterfaceStyle == .dark
            if changed { completion?(isDark) }
        }
    }
}
