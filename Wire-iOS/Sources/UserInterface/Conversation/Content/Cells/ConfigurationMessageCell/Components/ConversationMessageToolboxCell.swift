
import UIKit

final class ConversationMessageToolboxCell: UIView, ConversationMessageCell, MessageToolboxViewDelegate {
    
    struct Configuration {
        let message: ZMConversationMessage
        let selected: Bool
    }
    
    let toolboxView = MessageToolboxView()
    weak var delegate: ConversationMessageCellDelegate?
    weak var message: ZMConversationMessage?
    
    var isSelected: Bool = false
    var observerToken: Any?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
        configureConstraints()
    }
    
    private func configureSubviews() {
        toolboxView.delegate = self
        addSubview(toolboxView)
    }
    
    private func configureConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        toolboxView.translatesAutoresizingMaskIntoConstraints = false
        toolboxView.fitInSuperview()
    }
    
    func willDisplay() {
        toolboxView.startCountdownTimer()
    }
    
    func didEndDisplaying() {
        toolboxView.stopCountdownTimer()
    }
    
    func configure(with object: Configuration, animated: Bool) {
        toolboxView.configureForMessage(object.message, forceShowTimestamp: object.selected, animated: animated)
    }
    
    private func perform(action: MessageAction) {
        delegate?.perform(action: action, for: message, view: selectionView ?? self)
    }
    
    func messageToolboxViewDidRequestLike(_ messageToolboxView: MessageToolboxView) {
        perform(action: .like)
    }
    
    func messageToolboxViewDidSelectDelete(_ messageToolboxView: MessageToolboxView) {
        perform(action: .delete)
    }
    
    func messageToolboxViewDidSelectResend(_ messageToolboxView: MessageToolboxView) {
        perform(action: .resend)
    }
    
}

class ConversationMessageToolboxCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationMessageToolboxCell
    let configuration: View.Configuration
    
    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 2
    let isFullWidth: Bool = true
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = false
    
    let accessibilityIdentifier: String? = "MessageToolbox"
    let accessibilityLabel: String? = nil
    
    init(message: ZMConversationMessage, selected: Bool) {
        self.message = message
        self.configuration = View.Configuration(message: message, selected: selected)
    }
    
}
