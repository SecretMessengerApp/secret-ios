

import UIKit

extension UIImage {
    
    func dynamic(
        tintColor scheme: ThemeSchemeColor,
        renderingMode: RenderingMode = .alwaysTemplate
    ) -> UIImage {
        dynamic(tintColor: .dynamic(scheme: scheme), renderingMode: renderingMode)
    }
    
    func dynamic(
        tintColor: UIColor,
        renderingMode: RenderingMode = .alwaysTemplate
    ) -> UIImage {
        if #available(iOS 13.0, *) {
            return withTintColor(tintColor, renderingMode: renderingMode)
        } else {
            return self
        }
    }
}
