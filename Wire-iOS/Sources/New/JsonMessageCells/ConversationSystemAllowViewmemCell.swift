

import UIKit

class ConversationSystemAllowViewmemCell: ConversationMessageCellDescription {
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
    
    let accessibilityIdentifier: String? = "SystemAllowViewmemCell"
    let accessibilityLabel: String? = nil
    
    init(message: ZMConversationMessage) {
        self.message = message
        self.configuration = View.Configuration(
            icon: nil,
            attributedText: NSAttributedString(
                string: message.allowViewmen,
                attributes: View.baseAttributes
            ),
            showLine: true
        )
    }
}

