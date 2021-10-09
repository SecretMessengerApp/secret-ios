
import UIKit

extension UserType {

    /// Returns the current accent color of the user.
    var accentColor: UIColor {
        return UIColor(fromZMAccentColor: accentColorValue)
    }

}

extension UnregisteredUser {

    /// The accent color value of the unregistered user.
    var accentColor: AccentColor? {
        get {
            return accentColorValue.flatMap(AccentColor.init)
        }
        set {
            accentColorValue = newValue?.zmAccentColor
        }
    }

}
