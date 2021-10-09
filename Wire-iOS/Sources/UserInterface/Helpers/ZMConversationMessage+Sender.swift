
import Foundation

extension ZMConversationMessage {

    var senderName: String {
        guard let sender = self.sender else { return "conversation.status.someone".localized }
        if sender.isSelfUser {
            return "conversation.status.you".localized
        } else if let conversation = self.conversation {
            return sender.displayName(in: conversation)
        } else {
            return sender.displayName
        }
    }

    // TODO: ZMConversationMessage should add receiver, like sender
    var receiverName: String? {
        guard let sender = self.sender,
            let conversation = conversation,
            let user = conversation.sortedOtherParticipants.first else { return "conversation.status.someone".localized }
        if sender.isSelfUser {
            return user.displayName(in: conversation)
        } else {
            return "conversation.status.you".localized
        }
    }
    
}
