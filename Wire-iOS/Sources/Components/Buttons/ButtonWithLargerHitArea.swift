import UIKit

class ButtonWithLargerHitArea: UIButton {
    
    // MARK: - Properties
    
    var hitAreaPadding = CGSize.zero
    
    // MARK: - Init / Deinit
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUp()
    }
    
    private func setUp() {
        isAccessibilityElement = true
    }
    
     // MARK: - Overridden methods
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isHidden || alpha == 0 || !isUserInteractionEnabled || !isEnabled {
            return false
        }
        
        return bounds.insetBy(dx: -hitAreaPadding.width, dy: -hitAreaPadding.height).contains(point)
    }
    
}
    
