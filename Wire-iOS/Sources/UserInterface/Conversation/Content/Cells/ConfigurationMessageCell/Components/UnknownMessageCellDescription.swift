
import Foundation

extension CustomMessageView: ConversationMessageCell {

    var selectionView: UIView? {
        return messageLabel
    }

    func configure(with object: String, animated: Bool) {
        messageText = object
    }
}

/**
 * A description for a message cell that informs the user a message cannot be rendered.
 */

class UnknownMessageCellDescription: ConversationMessageCellDescription {
    typealias View = CustomMessageView
    let configuration: String

    weak var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 0

    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil

    let isFullWidth: Bool = false
    let supportsActions: Bool = false
    let containsHighlightableContent = false

    init() {
        self.configuration = "content.system.unknown_message.body".localized
    }

}
