
import UIKit

enum CallActionAppearance: Equatable {
    case audio, video
    
    var showBlur: Bool {
        switch self {
        case .audio: return false
        case .video: return true
        }
    }
    
    var backgroundColorNormal: UIColor {
        switch self {
        case .audio:
            return .dynamic(light: UIColor.lightGraphite.withAlphaComponent(0.08),
                         dark: UIColor.white.withAlphaComponent(0.24))
        case .video:
            return UIColor.white.withAlphaComponent(0.24)
        }
    }
    
    var backgroundColorSelected: UIColor {
        switch self {
        case .audio:
            return .dynamic(light: UIColor.from(scheme: .iconNormal, variant: .light),
                            dark: UIColor.from(scheme: .iconNormal, variant: .dark))
        case .video: return UIColor.from(scheme: .iconNormal, variant: .dark)
        }
    }
    
    var iconColorNormal: UIColor {
        switch self {
        case .audio:
            return .dynamic(light: UIColor.from(scheme: .iconNormal, variant: .light),
                            dark: UIColor.from(scheme: .iconNormal, variant: .dark))
        case .video: return UIColor.from(scheme: .iconNormal, variant: .dark)
        }
    }
    
    var iconTitleColorNormal: UIColor {
        switch self {
        case .audio:
            return .dynamic(light: UIColor.from(scheme: .iconNormal, variant: .light),
                            dark: UIColor.from(scheme: .iconNormal, variant: .dark))
        case .video: return UIColor.from(scheme: .iconNormal, variant: .dark)
        }

    }
    
    var iconColorSelected: UIColor {
        switch self {
        case .audio:
            return .dynamic(light: UIColor.from(scheme: .iconNormal, variant: .dark),
                            dark: UIColor.from(scheme: .iconNormal, variant: .light))
        case .video: return UIColor.from(scheme: .iconNormal, variant: .light)
        }
    }
    
    var backgroundColorSelectedAndHighlighted: UIColor {
        switch self {
        case .audio:
            return .dynamic(light: UIColor.black.withAlphaComponent(0.16),
                            dark: UIColor.white.withAlphaComponent(0.4))
        case .video: return  UIColor.white.withAlphaComponent(0.4)
        }
       
    }
}
