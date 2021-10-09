

import Foundation


extension ZMConversationMessage {

    var canBeLiked: Bool {
        guard let conversation = self.conversation else {
            return false
        }

        let participatesInConversation = conversation.activeParticipants.contains(ZMUser.selfUser())
        let sentOrDelivered = deliveryState.isOne(of: .sent, .delivered, .read)
        let likableType = isNormal && !isKnock
        return participatesInConversation && sentOrDelivered && likableType && !isObfuscated && !isEphemeral
    }

    var liked: Bool {
        set {
            let message: ZMClientMessage?
            if newValue {
               message = ZMMessage.addReaction(.like, toMessage: self)
            }
            else {
               message = ZMMessage.removeReaction(onMessage: self)
            }
            message?.unblock = true
        }
        get {
            return likers().contains(.selfUser())
        }
    }
    
    func hasLikeReactions() -> Bool {
        return usersReaction
            .filter { $0.key == MessageReaction.like.unicodeValue }
            .map { $0.value.count }
            .reduce(0, +)
            > 0
    }

    func likers() -> [ZMUser] {
        return usersReaction.filter { (reaction, _) -> Bool in
            reaction == MessageReaction.like.unicodeValue
            }.map { (_, users) in
                return users
            }.first ?? []
    }

    var sortedLikers: [ZMUser] {
        return likers().sorted { $0.displayName < $1.displayName }
    }

}

extension Message {

    @objc static func setLikedMessage(_ message: ZMConversationMessage, liked: Bool) {
        return message.liked = liked
    }

    @objc static func isLikedMessage(_ message: ZMConversationMessage) -> Bool {
        return message.liked
    }

    @objc static func hasLikeReactions(_ message: ZMConversationMessage) -> Bool {
        return message.hasLikeReactions()
    }

    @objc static func hasLikers(_ message: ZMConversationMessage) -> Bool {
        return !message.likers().isEmpty
    }

    @objc class func messageCanBeLiked(_ message: ZMConversationMessage) -> Bool {
        return message.canBeLiked
    }
    
}
