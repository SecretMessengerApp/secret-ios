
import UIKit

final class KeyboardBlockObserver: NSObject {
    
    struct ChangeInfo {
        enum Kind {
            case show, hide, change
        }

        let frame: CGRect
        let animationDuration: TimeInterval
        let kind: Kind
        let isKeyboardCollapsed: Bool?

        init?(_ note: Notification, kind: Kind) {
            guard let info = note.userInfo else { return nil }
            guard let endFrameValue = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
                let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return nil }
            frame = endFrameValue
            animationDuration = duration
            self.kind = kind

            if let beginFrameValue = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                /// key board is collapsed if init height is 0 or its is out of the screen bound
                if endFrameValue.height == 0 ||
                    endFrameValue.minY >= UIScreen.main.bounds.maxY ||
                    (endFrameValue == beginFrameValue &&
                     beginFrameValue.maxY > UIScreen.main.bounds.maxY &&
                     beginFrameValue.origin.y == UIScreen.main.bounds.maxY)
                    {
                    isKeyboardCollapsed = true
                } else {
                    isKeyboardCollapsed = beginFrameValue.height > endFrameValue.height && kind == .hide
                }
            } else {
                isKeyboardCollapsed = nil
            }
        }
    }
    
    typealias ChangeBlock = (ChangeInfo) -> Void
    
    private let changeBlock: ChangeBlock
    private let center = NotificationCenter.default
    
    init(block: @escaping ChangeBlock) {
        self.changeBlock = block
        super.init()
        registerKeyboardObservers()
    }
    
    deinit {
        center.removeObserver(self)
    }
    
    private func registerKeyboardObservers() {
        center.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ note: Notification) {
        ChangeInfo(note, kind: .show).apply(changeBlock)
    }
    
    @objc private func keyboardWillHide(_ note: Notification) {
        ChangeInfo(note, kind: .hide).apply(changeBlock)
    }
    
    @objc private func keyboardWillChangeFrame(_ note: Notification) {
        ChangeInfo(note, kind: .change).apply(changeBlock)
    }
    
}
