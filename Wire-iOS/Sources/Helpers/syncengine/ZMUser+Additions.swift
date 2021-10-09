
import WireDataModel


extension ZMUser {
    
    var canSeeServices: Bool {
        #if ADD_SERVICE_DISABLED
        return false
        #else
        return hasTeam
        #endif
    }

    var nameAccentColor: UIColor? {
        return UIColor.nameColor(for: accentColorValue, variant: ColorScheme.default.variant)
    }

    /// Blocks user if not already blocked and vice versa.
    func toggleBlocked() {
        if isBlocked {
            accept()
        } else {
            block()
        }
    }
}
