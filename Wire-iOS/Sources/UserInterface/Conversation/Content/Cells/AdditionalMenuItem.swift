
import Foundation

final class AdditionalMenuItem: NSObject {

    let item: UIMenuItem
    
    @objc(availableInEphemeralConversations)
    let isAvailableInEphemeralConversations: Bool
    
    init(item: UIMenuItem, allowedInEphemeralConversations: Bool) {
        self.item = item
        self.isAvailableInEphemeralConversations = allowedInEphemeralConversations
        super.init()
    }
    
    static func allowedInEphemeral(_ item: UIMenuItem) -> AdditionalMenuItem {
        return .init(item: item, allowedInEphemeralConversations: true)
    }
    
    static func forbiddenInEphemeral(_ item: UIMenuItem) -> AdditionalMenuItem {
        return .init(item: item, allowedInEphemeralConversations: false)
    }
}
