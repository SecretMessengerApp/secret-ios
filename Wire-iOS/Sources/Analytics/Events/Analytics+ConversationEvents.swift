

import Foundation

public enum ConversationEvent: Event {

    static let toggleAllowGuestsName = "guest_rooms.allow_guests"

    case toggleAllowGuests(value: Bool)

    var attributes: [AnyHashable : Any]? {
        switch self {
        case let .toggleAllowGuests(value: value):
            return ["is_allow_guests" : value]
        }
    }

    var name: String {
        switch self {
        case .toggleAllowGuests:
            return ConversationEvent.toggleAllowGuestsName
        }
    }
}

extension Analytics {
    public func tagAllowGuests(value: Bool) {
        tag(ConversationEvent.toggleAllowGuests(value: value))
    }
}
