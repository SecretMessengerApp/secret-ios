

import UIKit

enum ThemeSchemeColor: Int {
    
    case brand
    
    case title
    case subtitle
    
    /// sectionHeader/Footer
    case note
    
    case disable
    
    case background
    case secondaryBackground
    case barBackground
    case groupBackground
    case inputBackground
    case panelBackground
    case popoverBackground
    case badgeBackground
    
    case btnDisabledBackground
    
    case cellBackground
    case cellSelectedBackground
    
    case accessory
    case barTint
    case separator
    case alertButton
    
    case danger
    case placeholder
    
    case iconNormal
    case iconHighlighted
    
    case tabNormal
    case tabSelected
    case tabHighlighted
    
    case tabBarItemNormal
    case tabBarItemSelected
    
    case loadingDotActive
    case loadingDotInactive
    
    case accentDimmedFlat
    
    case unreadPing
    case silenced
    
    case markdownCode
    
    case iconShadow
    case activeCall
}

extension UIColor {
    
    static func dynamic(scheme: ThemeSchemeColor) -> UIColor {
        ColorFactory.make(scheme: scheme)
    }
    
    static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        ColorFactory.make(light: light, dark: dark)
    }
}

enum ColorFactory {
    
    fileprivate static func make(scheme: ThemeSchemeColor) -> UIColor {
        switch scheme {
        case .brand:                    return UIColor(hex: "#239CFA")
            
        case .title:                    return make(light: "#333333", dark: "#F5F5F5")
        case .subtitle:                 return make(light: "#666666", dark: "#A1A1A1")
        case .note:                     return make(light: "#999999", dark: "#EBEBF599")
        
        case .disable:                  return UIColor(hex: "#A1A1A1")

        case .background:               return make(light: "#FFFFFF", dark: "#080808")
        case .secondaryBackground:      return make(light: "#F2F2F7", dark: "#1C1C1E")
        case .barBackground:            return make(light: "#FFFFFF", dark: "#111111")
        case .groupBackground:          return make(light: "#F7F7F7", dark: "#080808")
        case .inputBackground:          return make(light: "#EFEFF0", dark: "#1C1C1E")
        case .panelBackground:          return make(light: "#FFFFFF", dark: "#2C2C2C")
        case .popoverBackground:        return UIColor(hex: "#232323")
        case .badgeBackground:          return make(light: "#A1A1A1", dark: "#2C2C2E")
            
        case .btnDisabledBackground:    return UIColor(hex: "#78C0F8")

        case .cellBackground:           return make(light: "#FFFFFF", dark: "#111111")
        case .cellSelectedBackground:   return make(light: "#f7f7f7", dark: "#2C2C2E")

        case .accessory:                return make(light: .blackAlpha40, dark: .whiteAlpha40)
        case .barTint:                  return make(light: "#000000", dark: "#BCBCBC")
        case .separator:                return make(light: "#DCDCDC", dark: "#38383A")
        case .alertButton:              return make(light: "#000000", dark: "#239CFA")
        case .danger:                   return UIColor(hex: "#FF3B30")
        case .placeholder:              return UIColor(hex: "#A1A1A1")
            
        case .iconNormal:               return make(light: "#000000", dark: "#BCBCBC")
        case .iconHighlighted:          return .white
            
        case .tabNormal:                return make(light: .blackAlpha48, dark: .whiteAlpha56)
        case .tabSelected:              return make(light: .graphite, dark: .white)
        case .tabHighlighted:           return make(light: .lightGraphite, dark: .lightGraphiteAlpha48)
            
        case .tabBarItemNormal:         return make(light: .lightGray, dark: UIColor(hex: "#A1A1A1"))
        case .tabBarItemSelected:       return make(light: .black, dark: .white)
            
        case .loadingDotActive:         return make(light: .graphiteAlpha40, dark: .whiteAlpha40)
        case .loadingDotInactive:       return make(light: .graphiteAlpha16, dark: .whiteAlpha16)
            
        case .accentDimmedFlat:
            return make(
                light: UIColor.accent().withAlphaComponent(0.16).removeAlphaByBlending(with: .white),
                dark: UIColor.accent().withAlphaComponent(0.30).removeAlphaByBlending(with: .black)
            )
        
        case .unreadPing, .silenced:    return make(light: "#FFFFFF", dark: "#777777")
        
        case .markdownCode:             return make(light: .darkGray, dark: UIColor(hex: "#BCBCBC"))
        case .iconShadow:               return make(light: .blackAlpha8, dark: .blackAlpha24)
        case .activeCall:               return make(light: .strongLimeGreen, dark: .strongLimeGreen)
        }
    }
    
    static func make(light: String, dark: String) -> UIColor {
        return make(light: UIColor(hex: light), dark: UIColor(hex: dark))
    }
    
    fileprivate static func make(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { trait -> UIColor in
                trait.userInterfaceStyle == .dark ? dark : light
            }
        } else {
            return light
        }
    }
}


@available(iOS 13.0, *)
enum AppTheme {
        
    private(set) static var current: UIUserInterfaceStyle {
        get {
            let raw = defaults.integer(forKey: themeKey)
            return UIUserInterfaceStyle(rawValue: raw) ?? .unspecified
        }
        set {
            guard current != newValue else { return }
            defaults.set(newValue.rawValue, forKey: themeKey)
            defaults.synchronize()
        }
    }
    
    private static let defaults = UserDefaults.standard
    private static let themeKey = "secret_theme_key"
        
    static func `switch`(to theme: UIUserInterfaceStyle) {
        current = theme
        UIApplication.shared.windows.forEach { $0.overrideUserInterfaceStyle = theme }
        AppDelegate.shared.window?.overrideUserInterfaceStyle = theme
        AppDelegate.shared.rootViewController.overrideUserInterfaceStyle = theme
    }
}

@available(iOS 13.0, *)
extension UIUserInterfaceStyle {
    
    var description: String {
        switch self {
        case .unspecified: return "self.settings.dark_mode.state_system.title".localized
        case .light: return "self.settings.dark_mode.state_light.title".localized
        case .dark: return "self.settings.dark_mode.state_dark.title".localized
        }
    }
}
