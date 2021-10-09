
import Foundation
import WireDataModel

extension Analytics {
    func guestAttributes(in conversation: ZMConversation) -> [String : Any] {
        return [
            "is_allow_guests" : conversation.allowGuests,
            "user_type" : SelfUser.current.isGuest(in: conversation) ? "guest" : "user"
        ]
    }
}

protocol Event {
    var name: String { get }
    var attributes: [AnyHashable: Any]? { get }
}

extension Analytics {
    
    func tag(_ event: Event) {
        tagEvent(event.name, attributes: event.attributes as? [String : NSObject] ?? [:])
    }
    
}

enum GuestLinkEvent: Event {
    case created, copied, revoked, shared
    
    var name: String {
        switch self {
        case .created: return "guest_rooms.link_created"
        case .copied: return "guest_rooms.link_copied"
        case .revoked: return "guest_rooms.link_revoked"
        case .shared: return "guest_rooms.link_shared"
        }
    }
    
    var attributes: [AnyHashable : Any]? {
        return nil
    }
}

enum GuestRoomEvent: Event {
    case created
    
    var name: String {
        switch self {
        case .created: return "guest_rooms.guest_room_creation"
        }
    }
    
    var attributes: [AnyHashable : Any]? {
        return nil
    }
}

extension Event {
    func track() {
        Analytics.shared().tag(self)
    }
}
