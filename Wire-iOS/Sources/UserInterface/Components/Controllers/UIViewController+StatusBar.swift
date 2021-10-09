
import Foundation

extension UIViewController {

    func updateStatusBar(onlyFullScreen: Bool) {
        UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(false, onlyFullScreen: onlyFullScreen)
    }

    @objc
    func updateStatusBar() {
        updateStatusBar(onlyFullScreen: false)
    }
}
