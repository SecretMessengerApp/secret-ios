
import Foundation

extension UIViewController {

    /// return true if the view controller's view is in a window, not covered by a modelled VC and the bounds is intersects with the screen's bound
    var isVisible: Bool {
        let isInWindow = view.window != nil
        let notCoveredModally = presentedViewController == nil
        let viewIsVisible = view.isVisible

        return isInWindow && notCoveredModally && viewIsVisible
    }

}

extension UIView {
    var isVisible: Bool {
        return convert(bounds, to: nil).intersects(UIScreen.main.bounds)
    }
}
