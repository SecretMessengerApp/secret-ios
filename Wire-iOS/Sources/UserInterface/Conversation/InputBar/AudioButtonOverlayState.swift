

import Foundation

enum AudioButtonOverlayState {
    case hidden, expanded(CGFloat), `default`
    
    var width: CGFloat {
        return 40
    }
    
    var height: CGFloat {
        switch self {
        case .hidden: return 0
        case .default: return 96
        case .expanded: return 120
        }
    }
    
    var alpha: CGFloat {
        switch self {
        case .hidden: return 0
        default: return 1
        }
    }
}

// MARK: Animation

extension AudioButtonOverlayState {
    
    var animatable: Bool {
        if case .hidden = self {
            return false
        }
        
        return true
    }
    
    var springDampening: CGFloat {
        switch self {
        case .expanded: return 0.6
        case .default: return 0.7
        default: return 0
        }
    }
    
    var springVelocity: CGFloat {
        switch self {
        case .expanded: return 0.4
        case .default: return 0.3
        default: return 0
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .expanded, .default: return 0.3
        default: return 0.2
        }
    }
    
    var sendButtonTransform: CGAffineTransform {
        switch self {
        case .hidden: return CGAffineTransform(rotationAngle: 90)
        default: return CGAffineTransform.identity
        }
    }
    
    func colorWithColors(_ color: UIColor, highlightedColor: UIColor) -> UIColor {
        if case .expanded(let amount) = self {
            return color.mix(highlightedColor, amount: amount)
        }
        return color
    }
}
