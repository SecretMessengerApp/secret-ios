
import UIKit

private let WireLastCachedKeyboardHeightKey = "WireLastCachedKeyboardHeightKey"

extension UIView {

    /// Provides correct handling for animating alongside a keyboard animation
    class func animate(
        withKeyboardNotification notification: Notification?,
        in view: UIView,
        delay: TimeInterval = 0,
        animations: @escaping (_ keyboardFrameInView: CGRect) -> Void,
        completion: ResultHandler? = nil
    ) {
        let keyboardFrame = self.keyboardFrame(in: view, forKeyboardNotification: notification)

        if let currentFirstResponder = UIResponder.currentFirst {
            let keyboardSize = CGSize(width: keyboardFrame.size.width, height: keyboardFrame.size.height - (currentFirstResponder.inputAccessoryView?.bounds.size.height ?? 0))
            setLastKeyboardSize(keyboardSize)
        }

        let userInfo = notification?.userInfo
        let animationLength: TimeInterval = (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurve: AnimationCurve = AnimationCurve(rawValue: (userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as AnyObject).intValue ?? 0) ?? .easeInOut

        var animationOptions: UIView.AnimationOptions = .beginFromCurrentState

        switch animationCurve {
        case .easeIn:
            animationOptions.insert(.curveEaseIn)
        case .easeInOut:
            animationOptions.insert(.curveEaseInOut)
        case  .easeOut:
            animationOptions.insert(.curveEaseOut)
        case  .linear:
            animationOptions.insert(.curveLinear)
        default:
            break
        }

        UIView.animate(withDuration: animationLength, delay: delay, options: animationOptions, animations: {
            animations(keyboardFrame)
        }, completion: completion)
    }
    
    class func setLastKeyboardSize(_ lastSize: CGSize) {
        UserDefaults.standard.set(NSCoder.string(for: lastSize), forKey: WireLastCachedKeyboardHeightKey)
    }
    
    class var lastKeyboardSize: CGSize {

        if let currentLastValue = UserDefaults.standard.object(forKey: WireLastCachedKeyboardHeightKey) as? String {
            var keyboardSize = NSCoder.cgSize(for: currentLastValue)

            // If keyboardSize value is clearly off we need to pull default value
            if keyboardSize.height < 150 {
                keyboardSize.height = KeyboardHeight.current
            }

            return keyboardSize
        }

        return CGSize(width: UIScreen.main.bounds.size.width, height: KeyboardHeight.current)
    }
    
    class func keyboardFrame(in view: UIView, forKeyboardNotification notification: Notification?) -> CGRect {
        let userInfo = notification?.userInfo
        return keyboardFrame(in: view, forKeyboardInfo: userInfo)
    }
    
    class func keyboardFrame(in view: UIView, forKeyboardInfo keyboardInfo: [AnyHashable: Any]?) -> CGRect {
        let screenRect = keyboardInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let windowRect = view.window?.convert(screenRect ?? CGRect.zero, from: nil)
        let viewRect = view.convert(windowRect ?? CGRect.zero, from: nil)

        let intersection = viewRect.intersection(view.bounds)

        return intersection
    }
}
