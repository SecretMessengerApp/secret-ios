
import Foundation

public enum SlideDirection: UInt {
    case up
    case down
}

public extension UIView {
    func wr_animateSlideTo(_ direction: SlideDirection = .down, newState: ()->()) {
        guard let superview = self.superview, let screenshot = snapshotView(afterScreenUpdates: false) else {
            return newState()
        }
        
        let offset = direction == .down ? -self.frame.size.height : self.frame.size.height
        screenshot.frame = self.frame
        superview.addSubview(screenshot)
        
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y + offset, width: self.frame.size.width, height: self.frame.size.height)
        
        newState()
        
        UIView.animate(easing: .easeInOutExpo, duration: 0.20, animations: {
            self.frame = screenshot.frame
            screenshot.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y - offset, width: self.frame.size.width, height: self.frame.size.height)
            }) { _ in
                
                screenshot.removeFromSuperview()
        }
    }
}
