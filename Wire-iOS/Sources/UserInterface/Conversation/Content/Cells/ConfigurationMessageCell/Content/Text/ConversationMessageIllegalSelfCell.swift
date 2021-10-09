
import UIKit
import Cartography

final class ConversationMessageIllegalSelfCell: UIView, ConversationMessageCell {
    
    struct Configuration {
        let text: String
        let message: ZMConversationMessage
    }
    
    var configuration: Configuration?
    
    private let messageBackView = UIImageView()
    private let warnImgView = UIImageView()
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .dynamic(scheme: .note)
        label.numberOfLines = 0
        return label
    }()
    
    var isSelected: Bool = false
    
    weak var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var menuPresenter: ConversationMessageCellMenuPresenter?
    
    var selectionView: UIView? {
        return messageBackView
    }
    
    var selectionRect: CGRect {
        return messageBackView.bounds
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
        messageBackView.image = UIImage(named: MessageBackImage.mineWithTail.rawValue)
        addSubview(messageBackView)
        textLabel.backgroundColor = .clear
        textLabel.setContentHuggingPriority(.required, for: .vertical)
        textLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        warnImgView.image = UIImage(named: "warning")
        [textLabel, warnImgView].forEach(messageBackView.addSubview)
    }
    
    private func configureConstraints() {
        constrain(self, messageBackView) { containView, messageBackView in
            messageBackView.top == containView.top
            messageBackView.leading == containView.leading + 56
            messageBackView.trailing == containView.trailing - 16
            messageBackView.bottom == containView.bottom
        }
        
        constrain(messageBackView, textLabel, warnImgView) { (containView, messageTextView, warnImgView) in
            warnImgView.top == containView.top + 24
            warnImgView.centerX == containView.centerX
            warnImgView.width == 16
            warnImgView.height == warnImgView.width
            
            messageTextView.top == warnImgView.bottom + 16
            messageTextView.leading == containView.leading + 8
            messageTextView.trailing == containView.trailing - 8
            messageTextView.bottom == containView.bottom - 16
        }
    }
    
    func configure(with object: Configuration, animated: Bool) {
        configuration = object
        textLabel.text = object.text
    }
}


class ConversationMessageIllegalSelfCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationMessageIllegalSelfCell
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
        let text = "conversation.group.message.content.illegal".localized
        configuration = View.Configuration(text: text, message: message)
    }
    
}
