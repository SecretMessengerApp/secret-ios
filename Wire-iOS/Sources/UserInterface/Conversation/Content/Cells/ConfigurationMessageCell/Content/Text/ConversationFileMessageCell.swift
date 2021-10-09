
import UIKit

class ConversationFileMessageCell: RoundedView, ConversationMessageCell {

    struct Configuration {
        let message: ZMConversationMessage
        var isObfuscated: Bool {
            return message.isObfuscated
        }
    }
    private var messageBackgroundView = UIImageView()
    private let fileTransferView = FileTransferView(frame: .zero)
    private let obfuscationView = ObfuscationView(icon: .paperclip)
    
    weak var delegate: ConversationMessageCellDelegate? = nil
    weak var message: ZMConversationMessage? = nil

    var isSelected: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        configureConstraints()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
        configureConstraints()
    }

    private func configureSubviews() {
        messageBackgroundView.isUserInteractionEnabled = true
        addSubview(messageBackgroundView)
        
        shape = .rounded(radius: 4)
//        backgroundColor = .from(scheme: .placeholderBackground)
        clipsToBounds = true

        fileTransferView.delegate = self
        obfuscationView.isHidden = true

        messageBackgroundView.addSubview(self.fileTransferView)
        messageBackgroundView.addSubview(self.obfuscationView)
    }

    private func configureConstraints() {
        messageBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        fileTransferView.translatesAutoresizingMaskIntoConstraints = false
        obfuscationView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56),

            // messageBackgroundView
            messageBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            messageBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // fileTransferView
            fileTransferView.leadingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor),
            fileTransferView.topAnchor.constraint(equalTo: messageBackgroundView.topAnchor),
            fileTransferView.trailingAnchor.constraint(equalTo: messageBackgroundView.trailingAnchor),
            fileTransferView.bottomAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor),

            // obfuscationView
            obfuscationView.leadingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor),
            obfuscationView.topAnchor.constraint(equalTo: messageBackgroundView.topAnchor),
            obfuscationView.trailingAnchor.constraint(equalTo: messageBackgroundView.trailingAnchor),
            obfuscationView.bottomAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor),
        ])
    }

    func configure(with object: Configuration, animated: Bool) {
        /// messageBackgroundView
        let message = object.message
        let senderIsSelf = message.sender?.remoteIdentifier == ZMUser.selfUser()?.remoteIdentifier
        if senderIsSelf{
            messageBackgroundView.image = UIImage.init(named: MessageBackImage.mineWithTail.rawValue)
        }else{
            messageBackgroundView.image = UIImage.init(named: MessageBackImage.otherWithTail.rawValue)
        }
        fileTransferView.configure(for: object.message, isInitial: false)

        obfuscationView.isHidden = !object.isObfuscated
        fileTransferView.isHidden = object.isObfuscated

    }

    override public var tintColor: UIColor! {
        didSet {
            self.fileTransferView.tintColor = self.tintColor
        }
    }

    var selectionView: UIView! {
        return fileTransferView
    }

    var selectionRect: CGRect {
        return fileTransferView.bounds
    }

}

extension ConversationFileMessageCell: TransferViewDelegate {
    func transferView(_ view: TransferView, didSelect action: MessageAction) {
        guard let message = message else { return }
        
        delegate?.perform(action: action, for: message, view: self)
    }
}

class ConversationFileMessageCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationFileMessageCell
    let configuration: View.Configuration

    var topMargin: Float = 8
    var showEphemeralTimer: Bool = false

    let isFullWidth: Bool = false
    let supportsActions: Bool = true
    let containsHighlightableContent: Bool = true

    weak var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?

    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil

    init(message: ZMConversationMessage) {
        self.configuration = View.Configuration(message: message)
    }
        
}
