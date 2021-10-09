
import Foundation

protocol UserRightInterface {
    static func selfUserIsPermitted(to permission: UserRight.Permission) -> Bool
}

final class UserRight: UserRightInterface {
    enum Permission {
        case resetPassword,
             editName,
             editHandle,
             editEmail,
             editPhone,
             editProfilePicture,
             editAccentColor
    }

    static func selfUserIsPermitted(to permission: UserRight.Permission) -> Bool {
        let selfUser = ZMUser.selfUser()
        let usesCompanyLogin = selfUser?.usesCompanyLogin == true
        
        switch permission {
        case .editEmail:
//        #if EMAIL_EDITING_DISABLED
//            return false
//        #else
//            return isProfileEditable || !usesCompanyLogin
//        #endif
        return false
        case .resetPassword:
            return isProfileEditable || !usesCompanyLogin
        case .editProfilePicture:
            return true // NOTE we always allow editing for now since settting profile picture is not yet supported by SCIM
        case .editName,
             .editHandle,
             .editPhone,
             .editAccentColor:
			return isProfileEditable
        }
    }
    
    private static var isProfileEditable: Bool {
        return ZMUser.selfUser()?.managedByWire ?? true
    }
}

