

import Foundation

@objc class ConversationHitTestView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if  let btn = findAudioButtonOverlay(), !btn.isHidden {
            let cpoint = self.convert(point, to: btn)
            if btn.bounds.contains(cpoint) {
                return btn.hitTest(cpoint, with: event)
            }
        }
        return super.hitTest(point, with: event)
    }
    
    func findAudioButtonOverlay() -> UIView? {
        func findButton(views: [UIView]) -> UIView? {
            for v in views {
                if v is AudioButtonOverlay {
                    return v
                }
                if let subv = findButton(views: v.subviews) {
                    return subv
                }
            }
            return nil
        }
        let subviews = self.subviews
        if let view = findButton(views: subviews) {
            return view
        }
        return nil
    }
    
}
