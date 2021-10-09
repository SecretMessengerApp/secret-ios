
import Foundation

#if targetEnvironment(simulator)
typealias EditableUser = ZMUser & ZMEditableUser

protocol SelfUserProviderUI {
    static var selfUser: EditableUser { get }
}

extension ZMUser {

    /// Return self's User object
    ///
    /// - Returns: a ZMUser<ZMEditableUser> object for app target, or a MockUser object for test.
    @objc static func selfUser() -> EditableUser! {

        if let mockUserClass = NSClassFromString("MockUser") as? SelfUserProviderUI.Type {
            return mockUserClass.selfUser
        } else {
            guard let session = ZMUserSession.shared() else { return nil }

            return ZMUser.selfUser(inUserSession: session)
        }
    }
}
#else
extension ZMUser {

    /// Return self's User object
    ///
    /// - Returns: a ZMUser object for app target
     @objc static func selfUser() -> ZMUser! {
        guard let session = ZMUserSession.shared() else { return nil }

        return ZMUser.selfUser(inUserSession: session)
    }
}
#endif
