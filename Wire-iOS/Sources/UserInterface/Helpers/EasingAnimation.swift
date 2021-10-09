
import UIKit

/**
 * An animation that interpolates the values between a start and finish value,
 * along the selected curve, for the property at the given key path.
 *
 * The default curve is `linear`. The values of the key frames will be recomputed
 * every time the easing function, from value, to value or duration are changed.
 *
 * - warning: Do not set the `values` or `path` properties manually.
 */

@objc(WREasingAnimation)
public class EasingAnimation: CAKeyframeAnimation {

    /// The function to use to animate the progress.
    var easing: EasingFunction = .linear {
        didSet {
            timingFunction = easing.timingFunction
        }
    }

    /// The initial value for animated the key path.
    var fromValue: Any? = nil {
        didSet {
            updateValues()
        }
    }

    /// The final value to assign to the key path when the animation finishes.
    var toValue: Any? = nil  {
        didSet {
            updateValues()
        }
    }

    // MARK: - Animation Values

    private func updateValues() {

        guard let fromValue = self.fromValue, let toValue = self.toValue else {
            values = []
            return
        }

        values = [fromValue, toValue]
        
    }

}
