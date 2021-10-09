

extension ConversationMessageSectionController {
    
    func addJsonMessageCells() -> [AnyConversationMessageCellDescription] {
        var cells: [AnyConversationMessageCellDescription] = []
        guard let jsonMessageText = message.jsonTextMessageData?.jsonMessageText else {
            return cells
        }
        
        let object = ConversationJSONMessage(jsonMessageText)
        
        switch object.type {
        case .confirmAddContact:
            cells.append(AnyConversationMessageCellDescription(ConversationConfirmAddContactCellDescription(message: message)))
        case .inviteGroupMemberVerify:
            cells.append(AnyConversationMessageCellDescription(ConversationInviteGroupMemberVerifyCellDescription(message: message)))
        case .expression:
            if object.expression?.url.hasSuffix("tgs") ?? false {
                let cell = ConversationExpressionTgsCellDescription(message: message)
                cells.append(AnyConversationMessageCellDescription(cell))
            }
            if object.expression?.url.hasSuffix("gif") ?? false {
                let cell = ConversationExpressionGifCellDescription(message: message)
                cells.append(AnyConversationMessageCellDescription(cell))
            }
        case .screenShot:
            let screenShotCell = ConversationSystemScreenShotMsgCellDescription(message: message)
            cells.append(AnyConversationMessageCellDescription(screenShotCell))
        default:
            cells.append(AnyConversationMessageCellDescription(UnknownMessageCellDescription()))
        }
        return cells
    }
    
}
