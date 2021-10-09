
import WireDataModel

let conversationMediaCompleteActionEventName = "contributed"

fileprivate extension ZMConversation {
    var hasSyncedTimeout: Bool {
        if case .synced(_)? = self.messageDestructionTimeout {
            return true
        }
        else {
            return false
        }
    }
}

extension Analytics {

    func tagMediaActionCompleted(_ action: ConversationMediaAction, inConversation conversation: ZMConversation) {
        var attributes = conversation.ephemeralTrackingAttributes
        attributes["action"] = action.attributeValue

        if let typeAttribute = conversation.analyticsTypeString() {
            attributes["with_service"] = conversation.includesServiceUser
            attributes["conversation_type"] = typeAttribute
        }

        attributes["is_global_ephemeral"] = conversation.hasSyncedTimeout
        
        for (key, value) in guestAttributes(in: conversation) {
            attributes[key] = value
        }

        tagEvent(conversationMediaCompleteActionEventName, attributes: attributes)
    }

}
