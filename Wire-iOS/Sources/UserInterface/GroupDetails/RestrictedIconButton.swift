
import Foundation

final class RestrictedIconButton: IconButton, Restricted {
    var requiredPermissions: Permissions = [] {
        didSet {
            updateHidden()
        }
    }

    override public var isHidden: Bool {
        get {
            return shouldHide || super.isHidden
        }

        set {
            if shouldHide {
                super.isHidden = true
            } else {
                super.isHidden = newValue
            }
        }
    }

    init(requiredPermissions: Permissions) {
        super.init()

        self.requiredPermissions = requiredPermissions

        updateHidden()
    }
}
