
import Foundation

enum ConversationType: Int {
    case oneToOne
    case group
}

extension ConversationType {
    var analyticsTypeString : String {
        switch  self {
        case .oneToOne:     return "one_to_one"
        case .group:        return "group"
        }
    }
    
    static func type(_ conversation: ZMConversation) -> ConversationType? {
        switch conversation.conversationType {
        case .oneOnOne:
            return .oneToOne
        case .group, .hugeGroup:
            return .group
        default:
            return nil
        }
    }
}

extension ZMConversation {
    
    func analyticsTypeString() -> String? {
        return ConversationType.type(self)?.analyticsTypeString
    }
        
    /// Whether the conversation is a 1-on-1 conversation with a service user
    var isOneOnOneServiceUserConversation: Bool {
        guard self.activeParticipants.count == 2,
             let otherUser = self.firstActiveParticipantOtherThanSelf else {
            return false
        }
        
        return otherUser.serviceIdentifier != nil &&
                otherUser.providerIdentifier != nil
    }
    
    /// Whether the conversation includes at least 1 service user.
    var includesServiceUser: Bool {
//        guard let participants = lastServerSyncedActiveParticipants.array as? [UserType] else { return false }
//        return participants.any { $0.isServiceUser }
        return false
    }
    
    var sortedServiceUsers: [UserType] {
        guard let participants = lastServerSyncedActiveParticipants.array as? [UserType] else { return [] }
        return participants.filter { $0.isServiceUser }.sorted { $0.displayName < $1.displayName }
    }

    @objc
    var sortedOtherParticipants: [UserType] {
        guard let participants = lastServerSyncedActiveParticipants.array as? [UserType] else { return [] }
        return participants.filter { !$0.isServiceUser }.sorted { $0.displayName < $1.displayName }
    }

}

