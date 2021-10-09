
import Foundation

enum InviteSource {
    case manualInput, addressBook
}

extension Sequence where Element == InviteResult {
    var emails: [String] {
        return map {
            switch $0 {
            case .success(email: let email): return email
            case .failure(email: let email, _): return email
            }
        }
    }
}

extension InviteError {
    var errorDescription: String {
        return errorDescriptionLocalizationKey.localized
    }
    
    private var errorDescriptionLocalizationKey: String {
        switch self {
        case .alreadyRegistered: return "team.invite.error.already_registered"
        case .tooManyTeamInvitations: return "team.invite.error.too_many_invitations"
        default: return "team.invite.error.generic"
        }
    }
}
