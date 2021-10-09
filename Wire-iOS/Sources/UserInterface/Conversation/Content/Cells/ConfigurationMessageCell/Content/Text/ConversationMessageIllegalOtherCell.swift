
import UIKit
import Cartography

final class ConversationMessageIllegalOtherCell: UIView, ConversationMessageCell {

    struct Configuration {
        let text: String
        let message: ZMConversationMessage
    }
    
    var configuration: Configuration?
    private let iconImgView = ThemedImageView()
    private let messageTextView = WebLinkTextView()
    private let lineView = UIView()
    var isSelected: Bool = false
    
    weak var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var menuPresenter: ConversationMessageCellMenuPresenter?
    
    var selectionView: UIView? {
        return messageTextView
    }
    
    var selectionRect: CGRect {
        return messageTextView.bounds
    }
    
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
        iconImgView.image = StyleKitIcon.eyeDisable.makeImage(size: .like, color: .from(scheme: .iconNormal)).withColor(.dynamic(scheme: .iconNormal))
        addSubview(iconImgView)
        addSubview(messageTextView)
        addSubview(lineView)
        messageTextView.isEditable = false
        messageTextView.isSelectable = false
        messageTextView.backgroundColor = .clear
        messageTextView.isScrollEnabled = false
        messageTextView.textContainerInset = .zero
        messageTextView.textContainer.lineFragmentPadding = 0
        messageTextView.isUserInteractionEnabled = false
        messageTextView.accessibilityIdentifier = "Message"
        messageTextView.accessibilityElementsHidden = false
        iconImgView.setContentCompressionResistancePriority(.required, for: .horizontal)
        messageTextView.setContentHuggingPriority(.required, for: .vertical)
        messageTextView.setContentCompressionResistancePriority(.required, for: .vertical)
        messageTextView.font = FontSpec(.small, .light).font
        messageTextView.textColor = UIColor.dynamic(scheme: .title)
        lineView.backgroundColor = .dynamic(scheme: .separator)
    }
    
    private func configureConstraints() {
        constrain(self, iconImgView, messageTextView, lineView) { (containView, iconImgView, messageTextView, lineView) in
            iconImgView.centerY == containView.centerY
            iconImgView.leading == containView.leading + 56
            
            messageTextView.top == containView.top + 16
            messageTextView.leading == iconImgView.trailing + 8
            messageTextView.bottom == containView.bottom - 16
            
            lineView.leading == messageTextView.trailing + 16
            lineView.height == .hairline
            lineView.trailing == containView.trailing
            lineView.centerY == containView.centerY
        }
    }
    
    func configure(with object: Configuration, animated: Bool) {
        configuration = object
        messageTextView.text = object.text
    }
}


class ConversationMessageIllegalOtherCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationMessageIllegalOtherCell
    let configuration: View.Configuration
    
    weak var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 0
    
    let isFullWidth: Bool = true
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = true
    
    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil
    
    init(message: ZMConversationMessage) {
        let senderName = message.sender?.name ?? ""
        let operatorName = message.illegalOptName
        let text = "conversation.group.mark.message.illegal.by.admins".localized(args: operatorName, senderName)
        configuration = View.Configuration(text: text, message: message)
    }

}
