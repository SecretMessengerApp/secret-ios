

import Foundation


class ConversationSystemOptionScreenShotCellDescription: ConversationMessageCellDescription {
    
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
    
    let accessibilityIdentifier: String? = "OptionScreenShotCell"
    let accessibilityLabel: String? = nil
    
    init(message: ZMConversationMessage) {
        self.message = message
        self.configuration = View.Configuration(
            icon: nil,
            attributedText: NSAttributedString(
                string: message.screenShotStatus,
                attributes: View.baseAttributes
            ),
            showLine: true
        )
    }
}


class ConversationSystemScreenShotMsgCellDescription: ConversationMessageCellDescription {
    
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
    
    let accessibilityIdentifier: String? = "SystemScreenShotMsgCell"
    let accessibilityLabel: String? = nil
    
    init(message: ZMConversationMessage) {
        self.message = message
        
        let text = "content.system.screen.shot".localized(args: message.sender?.displayName ?? "")
        self.configuration = View.Configuration(
            icon: nil,
            attributedText: NSAttributedString(
                string: text,
                attributes: View.baseAttributes
            ),
            showLine: true
        )
        actionController = nil
    }
}
