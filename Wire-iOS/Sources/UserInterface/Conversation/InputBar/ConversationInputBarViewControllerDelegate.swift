

import WireDataModel

protocol ConversationInputBarViewControllerDelegate: class {
    func conversationInputBarViewControllerDidComposeText(text: String, mentions: [Mention], replyingTo message: ZMConversationMessage?)    
    func conversationInputBarViewControllerShouldBeginEditing(_ controller: ConversationInputBarViewController) -> Bool
    func conversationInputBarViewControllerShouldEndEditing(_ controller: ConversationInputBarViewController) -> Bool
    func conversationInputBarViewControllerDidFinishEditing(_ message: ZMConversationMessage, withText newText: String?, mentions: [Mention])
    func conversationInputBarViewControllerDidCancelEditing(_ message: ZMConversationMessage)
    func conversationInputBarViewControllerWants(toShow message: ZMConversationMessage)
    func conversationInputBarViewControllerEditLastMessage()
    func conversationInputBarViewControllerDidComposeDraft(message: DraftMessage)
}
