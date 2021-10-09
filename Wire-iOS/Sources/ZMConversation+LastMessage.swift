
import Foundation

extension ZMConversation {

    @objc
    public var lastConversationMessage: ZMConversationMessage? {

        if let visivleTimestamp = self.lastVisibleMessage?.serverTimestamp,
            let serviceTimestamp = self.lastServiceMessage?.systemMessage?.serverTimestamp {
            return (visivleTimestamp > serviceTimestamp)
                ? self.lastVisibleMessage : self.lastServiceMessage?.systemMessage
        }
        
        return self.lastVisibleMessage ?? self.lastServiceMessage?.systemMessage
    }
}
