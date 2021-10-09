
enum CallInfoViewControllerAccessoryType: Equatable {
    case none
    case avatar(ZMUser)
    case participantsList(CallParticipantsList)
    
    var showParticipantList: Bool {
        if case .participantsList = self {
            return true
        } else {
            return false
        }
    }
    
    var showAvatar: Bool {
        if case .avatar = self {
            return true
        } else {
            return false
        }
    }
    
    var participants: CallParticipantsList {
        switch self {
        case .participantsList(let participants):
            return participants
        default:
            return []
        }
    }
    
}
