
import UIKit

final class ConversationEncryptedSystemMessageCell: UIView, ConversationMessageCell {
    
    struct Configuration {
        let text: NSAttributedString
    }
    
    var configuration: Configuration?
    
    private let messageBackView = UIView()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .dynamic(scheme: .title)
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
        messageBackView.backgroundColor = .dynamic(light: UIColor(hex: "#FFF4C0"), dark: UIColor(hex: "#2C2C2E"))
        messageBackView.layer.cornerRadius = 8
        addSubview(messageBackView)
        textLabel.setContentHuggingPriority(.required, for: .vertical)
        textLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        messageBackView.addSubview(textLabel)
    }
    
    private func configureConstraints() {
        messageBackView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            messageBackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            messageBackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            messageBackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            messageBackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            textLabel.topAnchor.constraint(equalTo: messageBackView.topAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: messageBackView.leadingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: messageBackView.trailingAnchor, constant: -8),
            textLabel.bottomAnchor.constraint(equalTo: messageBackView.bottomAnchor, constant: -8)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(with object: Configuration, animated: Bool) {
        configuration = object
        textLabel.attributedText = object.text
    }
}


final class ConversationEncryptedSystemMessageCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationEncryptedSystemMessageCell
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
    
    init() {
        let text = "conversation.group.message.content.encrypted".localized
        let lockIcon = NSTextAttachment.textAttachment(
            for: .lockSVG,
            with: .dynamic(scheme: .title),
            iconSize: .tiny,
            verticalCorrection: -3
        )
        let attr = NSAttributedString(attachment: lockIcon) + " " + text
        configuration = View.Configuration(text: attr)
    }
}
