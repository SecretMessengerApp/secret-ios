
import Foundation

public extension Bundle {
    static var ssoURLScheme: String? {
        return Bundle.appMainBundle.infoForKey("Wire SSO URL Scheme")
    }
}

