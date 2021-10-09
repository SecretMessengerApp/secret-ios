
import UIKit
import SafariServices

class TintColorOverrider: NSObject {
    private var windowTintColor: UIColor?
    
    func override() {
        windowTintColor = UIApplication.shared.delegate?.window??.tintColor
        UIApplication.shared.delegate?.window??.tintColor = UIColor.dynamic(scheme: .title)
    }
    
    func restore() {
        UIApplication.shared.delegate?.window??.tintColor = windowTintColor
    }
}

/// These classes should be subclass from when setting the tint color
/// of controls doesn't have any effect, see `TintCorrectedActivityViewController` and
/// https://stackoverflow.com/questions/25795065/ios-8-uiactivityviewcontroller-and-uialertcontroller-button-text-color-uses-wind

class TintColorCorrectedViewController: UIViewController {
    private var overrider = TintColorOverrider()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrider.override()
        UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        overrider.restore()
        UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(true)
    }
}
