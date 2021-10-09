
import Foundation

class ConversationVideoMessageCell: RoundedView, ConversationMessageCell {
    
    struct Configuration {
        let message: ZMConversationMessage
        var isObfuscated: Bool {
            return message.isObfuscated
        }
    }

    private var messageBackgroundView = UIImageView()
    private let transferView = VideoMessageView(frame: .zero)
    private let obfuscationView = ObfuscationView(icon: .videoMessage)
    
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
        
        transferView.delegate = self
        obfuscationView.isHidden = true
        transferView.cornerRadius = 6
        obfuscationView.cornerRadius = 6
        messageBackgroundView.addSubview(self.transferView)
        messageBackgroundView.addSubview(self.obfuscationView)
    }
    
    private func configureConstraints() {
        messageBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        transferView.translatesAutoresizingMaskIntoConstraints = false
        obfuscationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 160.0),
            
            // messageBackgroundView
            messageBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            messageBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // transferView
            transferView.leadingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor, constant: 10),
            transferView.topAnchor.constraint(equalTo: messageBackgroundView.topAnchor, constant: 3),
            transferView.trailingAnchor.constraint(equalTo: messageBackgroundView.trailingAnchor, constant: -10),
            transferView.bottomAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor, constant: -3),
            
            // obfuscationView
            obfuscationView.leadingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor, constant: 8),
            obfuscationView.topAnchor.constraint(equalTo: messageBackgroundView.topAnchor, constant: 2),
            obfuscationView.trailingAnchor.constraint(equalTo: messageBackgroundView.trailingAnchor, constant: -8),
            obfuscationView.bottomAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor, constant: -2),
            ])
    }
    
    func configure(with object: Configuration, animated: Bool) {
        transferView.configure(for: object.message, isInitial: false)
        
        /// messageBackgroundView
        let message = object.message
        let senderIsSelf = message.sender?.remoteIdentifier == ZMUser.selfUser()?.remoteIdentifier
        if senderIsSelf{
            messageBackgroundView.image = UIImage.init(named: MessageBackImage.mineWithTail.rawValue)
        }else{
            messageBackgroundView.image = UIImage.init(named: MessageBackImage.otherWithTail.rawValue)
        }
        obfuscationView.isHidden = !object.isObfuscated
        transferView.isHidden = object.isObfuscated

    }
    
    override public var tintColor: UIColor! {
        didSet {
            self.transferView.tintColor = self.tintColor
        }
    }
    
    var selectionView: UIView! {
        return transferView
    }
    
    var selectionRect: CGRect {
        return transferView.bounds
    }
    
}

extension ConversationVideoMessageCell: TransferViewDelegate {
    func transferView(_ view: TransferView, didSelect action: MessageAction) {
        guard let message = message else { return }
        
        delegate?.perform(action: action, for: message, view: self)
    }
}

class ConversationVideoMessageCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationVideoMessageCell
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
