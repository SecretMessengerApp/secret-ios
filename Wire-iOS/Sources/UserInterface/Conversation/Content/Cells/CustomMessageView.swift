
import Foundation

class CustomMessageView: UIView {
    public var isSelected: Bool = false
    
    weak var delegate: ConversationMessageCellDelegate? = nil
    weak var message: ZMConversationMessage? = nil

    public var messageLabel = WebLinkTextView()
    var messageText: String? {
        didSet {
            messageLabel.text = messageText?.applying(transform: .upper)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        messageLabel.isAccessibilityElement = true
        messageLabel.accessibilityLabel = "Text"
        messageLabel.linkTextAttributes = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle().rawValue as NSNumber,
                                       NSAttributedString.Key.foregroundColor: ZMUser.selfUser().accentColor]

        super.init(frame: frame)
        addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageLabel.topAnchor.constraint(equalTo: topAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        messageLabel.font = FontSpec(.small, .light).font
        messageLabel.textColor = UIColor.dynamic(scheme: .title)
    }
}

// MARK: - UITextViewDelegate
extension CustomMessageView: UITextViewDelegate {

    public func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(url)
        return false
    }
}
