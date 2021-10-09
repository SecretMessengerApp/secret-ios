
enum TeamInviteEvent: Event {

    enum InviteMethod: String {
        case teamCreation = "team_creation"
    }
    
    case sentInvite(InviteMethod)
    
    var name: String {
        switch self {
        case .sentInvite: return "team.sent_invite"
        }
    }
    
    var attributes: [AnyHashable : Any]? {
        switch self {
        case .sentInvite(let method): return ["method": method.rawValue]
        }
    }
}
