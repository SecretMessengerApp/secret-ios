
import Foundation
import UIKit

private var ZM_UNUSED = "UI"
private var overridenAccentColor: ZMAccentColor = .undefined


extension UIColor {
    
    
    /// Set accent color on self user to this index.
    ///
    /// - Parameter accentColor: the accent color
    class func setAccent(_ accentColor: ZMAccentColor) {
        ZMUserSession.shared()?.enqueueChanges {
            SelfUser.provider?.selfUser.accentColorValue = accentColor
        }
    }
    
    class func indexedAccentColor() -> ZMAccentColor {
        // priority 1: overriden color
        if overridenAccentColor != .undefined {
            return overridenAccentColor
        }

        guard
            let activeUserSession = SessionManager.shared?.activeUserSession,
            activeUserSession.selfUser.accentColorValue != .undefined
        else {
            // priority 3: default color
            return .strongBlue
        }
        
        // priority 2: color from self user
        return activeUserSession.selfUser.accentColorValue
    }
    
    
    /// Set override accent color. Can set to ZMAccentColorUndefined to remove override.
    ///
    /// - Parameter overrideColor: the override color
    class func setAccentOverride(_ overrideColor: ZMAccentColor) {
        if overridenAccentColor == overrideColor {
            return
        }
        
        overridenAccentColor = overrideColor
    }

    static var accentDarken: UIColor {
        return accent().mix(.black, amount: 0.1).withAlphaComponent(0.32)
    }

    static var accentDimmedFlat: UIColor {
        .dynamic(scheme: .accentDimmedFlat)
    }

    class func accent() -> UIColor {
        return UIColor(fromZMAccentColor: indexedAccentColor())
    }

    static func buttonEmptyText(variant: ColorSchemeVariant) -> UIColor {
        switch variant {
        case .dark:
            return .white
        case .light:
            return accent()
        }
    }
}
