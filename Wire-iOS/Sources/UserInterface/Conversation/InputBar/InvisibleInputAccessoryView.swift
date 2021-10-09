

import Foundation
import UIKit

// Because the system manages the input accessory view lifecycle and positioning, we have to monitor what
// is being done to us and report back

protocol InvisibleInputAccessoryViewDelegate: class {
    func invisibleInputAccessoryView(_ invisibleInputAccessoryView: InvisibleInputAccessoryView, superviewFrameChanged frame: CGRect?)
}

final class InvisibleInputAccessoryView: UIView {
    weak var delegate: InvisibleInputAccessoryViewDelegate?
    private var frameObserver: NSKeyValueObservation?
    
    var overriddenIntrinsicContentSize: CGSize = .zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        return overriddenIntrinsicContentSize
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window != nil {
            frameObserver = superview!.observe(
                \UIView.center,
                options: []
            ) { [weak self] _, _ in
                self?.superviewFrameChanged()
            }
        } else {
            frameObserver = nil
        }
    }
    
    private func superviewFrameChanged() {
        delegate?.invisibleInputAccessoryView(self, superviewFrameChanged: superview?.frame)
    }
}
