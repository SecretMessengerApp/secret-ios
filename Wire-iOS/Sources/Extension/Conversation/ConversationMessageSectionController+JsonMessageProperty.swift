

extension ConversationMessageSectionController {
    
    func isJsonMessageSenderVisible(in context: ConversationMessageContext) -> Bool {
        guard message.sender != nil, !message.isKnock, !message.isSystem,
            [.group, .hugeGroup].contains(message.conversation?.conversationType) &&
                message.sender?.isSelfUser == false else {
                    return false
        }
        
        guard let jsonMessageText = message.jsonTextMessageData?.jsonMessageText else {
            return true
        }
        let object = ConversationJSONMessage(jsonMessageText)
        switch object.type {
        case .confirmAddContact:
            return false
        default:
            return true
        }
    }
    
}
