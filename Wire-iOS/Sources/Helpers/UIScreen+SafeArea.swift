
import UIKit

extension UIScreen {

    static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    

    static var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    

    static var isPortrait: Bool {
        return UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown
    }
    
    /// Status bar height
    static var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    @available(iOS, deprecated: 10.0, message: "not safe")
    @objc static var safeArea: UIEdgeInsets {
        if #available(iOS 11, *), hasNotch {
            return UIApplication.shared.keyWindow!.safeAreaInsets
        }
        return UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
    }

    static var hasBottomInset: Bool {
        if #available(iOS 11, *) {
            guard let window = UIApplication.shared.keyWindow else { return false }
            let insets = window.safeAreaInsets

            return insets.bottom > 0
        }

        return false
    }

    @objc static var hasNotch: Bool {
        if #available(iOS 12, *) {
            ///on iOS12 insets.top == 20 on device without notch.
            ///insets.top == 44 on device with notch.
            guard let window = UIApplication.shared.keyWindow else { return false }
            let insets = window.safeAreaInsets
            return insets.top > 20 || insets.bottom > 0
        } else if #available(iOS 11, *) {
            guard let window = UIApplication.shared.keyWindow else { return false }
            let insets = window.safeAreaInsets
            // if top or bottom insets are greater than zero, it means that
            // the screen has a safe area (e.g. iPhone X)
            return insets.top > 0 || insets.bottom > 0
        } else {
            return false
        }
    }
    
    var isCompact: Bool {
        return bounds.size.height <= 568
    }
}
