

@objc protocol ConversationMessageCellLegacyDelegate {

    @objc optional func conversationCellConfirmNewJsonMessage(message: ZMConversationMessage)
    
    @objc optional func conversationCellWantsToShowConversation(conversationID: String?, appID: String?, name: String?, icon: String?, content: String?)
    
    @objc optional func conversationCellWantsToAddFriend(uid: String)
    
    @objc optional func conversationDidRejectAppNoticeWith(appID: String?)
    
    @objc optional func conversationCellAIEndTyping()

    @objc optional func conversationCellJoinConversation(by inviteURL: URL)
    
    @objc optional func conversationCellWantsToOpen(url: URL)

    @objc optional func conversationCellWantsToMention(user: UserType)
}
