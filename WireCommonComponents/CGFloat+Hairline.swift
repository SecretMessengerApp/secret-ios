
import UIKit

extension CGFloat {
    public static var hairline: CGFloat {
        return 1.0 / UIScreen.main.scale
    }
}

extension UIScreen {
    @objc public static var hairline: CGFloat {
        return CGFloat.hairline
    }
}
