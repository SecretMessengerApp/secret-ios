

import Foundation

class ConversationSystemCreatorChangeMsgCellDescription: ConversationMessageCellDescription {
    
    typealias View = ConversationSystemMessageCell
    let configuration: View.Configuration
    
    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 8
    
    let isFullWidth: Bool = true
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = true
    
    let accessibilityIdentifier: String? = "SystemGroupManagerMsgCell"
    let accessibilityLabel: String? = nil
    
    init(message: ZMConversationMessage) {
        self.message = message
        var content = ""
        if let systemMessage = message as? ZMSystemMessage,
           let changedCreatorId = systemMessage.changeCreatorId,
           let uuid = UUID(uuidString: changedCreatorId),
           let user = ZMUser(remoteID: uuid) {
            content = user.displayName(in: message.conversation) + " " + "conversation.setting.creator.systemMsg.change".localized
        }
        let attributedText = NSAttributedString(
            string: content,
            attributes: View.baseAttributes
        )
        self.configuration = View.Configuration(icon: nil, attributedText: attributedText, showLine: true)
    }
}
