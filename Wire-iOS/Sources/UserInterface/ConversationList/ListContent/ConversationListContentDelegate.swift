

import Foundation

@objc
protocol ConversationListContentDelegate: NSObjectProtocol {
    @objc(conversationList:didSelectConversation:focusOnView:)
    func conversationList(_ controller: ConversationListContentController?, didSelect conversation: ZMConversation?, focusOnView focus: Bool)
    func conversationListDidSelectNotDisturbed(_ controller: ConversationListContentController?)
    /// This is called after a delete when there is an item to select
    func conversationList(_ controller: ConversationListContentController?, willSelectIndexPathAfterSelectionDeleted conv: IndexPath?)
    func conversationListDidScroll(_ controller: ConversationListContentController?)
    func conversationListContentController(_ controller: ConversationListContentController?, wantsActionMenuFor conversation: ZMConversation?, fromSourceView sourceView: UIView?)
}

protocol ConversationListContentBackDelegate: class {
    func backButtonClick()
}
