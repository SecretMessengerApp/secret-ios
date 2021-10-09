
import Foundation
import UIKit

extension UIControl.State {
    
    /// Expand UIControl.State to its contained states
    var expanded: [UIControl.State] {
        var expandedStates = [UIControl.State]()
        if self == .normal {
            expandedStates.append(.normal)
        }
        
        let states: [UIControl.State] = [.disabled, .highlighted, .selected]
        states.forEach() {
            if contains($0) {
                expandedStates.append($0)
            }
        }
        
        return expandedStates
    }
}
