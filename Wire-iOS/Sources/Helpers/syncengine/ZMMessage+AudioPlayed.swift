

import Foundation


extension Message {
    
    static func markAsPlayed(_ message: ZMConversationMessage) {
        message.markAsPlayed()
    }
    
    static func isMarkedAsPlayed(_ message: ZMConversationMessage) -> Bool {
        return message.isMarkedAsPlayed
    }
}


extension ZMConversationMessage {
    
    var isMarkedAsPlayed: Bool {
        set {
            let message = ZMMessage.addReaction(.audioPlayed, toMessage: self)
            message?.unblock = true
        }
        get {
            return usersReaction.keys
                .filter { $0 == MessageReaction.audioPlayed.unicodeValue }
                .isEmpty == false
//            return audioPlayedUsers().contains(.selfUser())
        }
    }
    
    private func audioPlayedUsers() -> [ZMUser] {
        return usersReaction
            .filter { reaction, _ in reaction == MessageReaction.audioPlayed.unicodeValue }
            .map { _, users in users}
            .first ?? []
    }
    
    private var canBeMarkedAsPlayed: Bool {

        guard
            isAudio,
            !isSentBySelfUser,
            !isMarkedAsPlayed
            else { return false }
        return true
    }
    
    func markAsPlayed() {
        if canBeMarkedAsPlayed {
            isMarkedAsPlayed = true
        }
    }
}
