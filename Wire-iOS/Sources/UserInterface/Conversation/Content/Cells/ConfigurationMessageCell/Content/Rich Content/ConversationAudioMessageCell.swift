
import Foundation

class ConversationAudioMessageCell: RoundedView, ConversationMessageCell {
    
    struct Configuration {
        let message: ZMConversationMessage
        var isObfuscated: Bool {
            return message.isObfuscated
        }
    }
    private var redDotView: RoundedView = {
        let view = RoundedView()
        view.shape = .circle
        view.backgroundColor = .red
        view.isHidden = true
        return view
    }()

    private var messageBackgroundView = UIImageView()
    private let transferView = AudioMessageView()
    private let obfuscationView = ObfuscationView(icon: .microphone)
    
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
        addSubview(redDotView)
        transferView.delegate = self
        obfuscationView.isHidden = true
        
        messageBackgroundView.addSubview(self.transferView)
        messageBackgroundView.addSubview(self.obfuscationView)
    }
    
    private var selfMessageBackgroundViewTrailingConstraint: NSLayoutConstraint!
    private var otherMessageBackgroundViewTrailingConstraint: NSLayoutConstraint!
    
    private func redDotViewConstraintActive(ifSenderIsOther value: Bool) {
        let constraints = [
            redDotView.centerYAnchor.constraint(equalTo: centerYAnchor),
            redDotView.trailingAnchor.constraint(equalTo: trailingAnchor),
            redDotView.widthAnchor.constraint(equalToConstant: 8),
            redDotView.heightAnchor.constraint(equalToConstant: 8)
        ]
        value
            ? NSLayoutConstraint.activate(constraints)
            : NSLayoutConstraint.deactivate(constraints)
    }
    
    private func configureConstraints() {
        messageBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        transferView.translatesAutoresizingMaskIntoConstraints = false
        obfuscationView.translatesAutoresizingMaskIntoConstraints = false
        redDotView.translatesAutoresizingMaskIntoConstraints = false
        
        selfMessageBackgroundViewTrailingConstraint = messageBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor)
        otherMessageBackgroundViewTrailingConstraint = messageBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56),
            
            // messageBackgroundView
            messageBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageBackgroundView.topAnchor.constraint(equalTo: topAnchor),
//            selfMessageBackgroundViewTrailingConstraint,
            messageBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // transferView
            transferView.leadingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor),
            transferView.topAnchor.constraint(equalTo: messageBackgroundView.topAnchor),
            transferView.trailingAnchor.constraint(equalTo: messageBackgroundView.trailingAnchor),
            transferView.bottomAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor),
            
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
        selfMessageBackgroundViewTrailingConstraint.isActive = senderIsSelf
        otherMessageBackgroundViewTrailingConstraint.isActive = !senderIsSelf
        redDotViewConstraintActive(ifSenderIsOther: !senderIsSelf)
        if senderIsSelf {
            redDotView.isHidden = true
            messageBackgroundView.image = UIImage(named: MessageBackImage.mineWithTail.rawValue)
        } else {
            redDotView.isHidden = object.message.isAudio && object.message.isMarkedAsPlayed
            messageBackgroundView.image = UIImage(named: MessageBackImage.otherWithTail.rawValue)
        }
        transferView.configure(for: object.message, isInitial: false)

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

extension ConversationAudioMessageCell: TransferViewDelegate {
    func transferView(_ view: TransferView, didSelect action: MessageAction) {
        guard let message = message else { return }
        
        delegate?.perform(action: action, for: message, view: self)
    }
}

class ConversationAudioMessageCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationAudioMessageCell
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
