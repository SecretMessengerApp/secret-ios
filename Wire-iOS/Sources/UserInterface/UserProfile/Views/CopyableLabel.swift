

import Foundation


/// This class is a drop-in replacement for UILabel which can be copied.
class CopyableLabel: UILabel {

    private let dimmedAlpha: CGFloat = 0.4
    private let dimmAnimationDuration: TimeInterval = 0.33

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressed)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
    }

    @objc private func longPressed(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began,
            let view = recognizer.view,
            let superview = view.superview,
            view == self,
            becomeFirstResponder() else { return }

        NotificationCenter.default.addObserver(self, selector: #selector(menuDidHide), name: UIMenuController.didHideMenuNotification, object: nil)
        UIMenuController.shared.setTargetRect(view.frame, in: superview)
        UIMenuController.shared.setMenuVisible(true, animated: true)
        fade(dimmed: true)
    }

    @objc private func menuDidHide(_ note: Notification) {
        NotificationCenter.default.removeObserver(self, name: UIMenuController.didHideMenuNotification, object: nil)
        fade(dimmed: false)
    }

    private func fade(dimmed: Bool) {
        UIView.animate(withDuration: dimmAnimationDuration) {
            self.alpha = dimmed ? self.dimmedAlpha : 1
        }
    }

}
