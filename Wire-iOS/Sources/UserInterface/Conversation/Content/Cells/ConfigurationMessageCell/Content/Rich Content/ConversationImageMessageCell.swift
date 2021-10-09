
import Foundation

class ConversationImageMessageCell: UIView, ConversationMessageCell {
    
    struct Configuration {
        let image: ZMImageMessageData
        let message: ZMConversationMessage
        var isObfuscated: Bool {
            return message.isObfuscated
        }
    }
    private var messageBackgroundView = UIImageView()
    private var containerView = UIView()
    private var imageResourceView = ImageResourceView()
    private let obfuscationView = ObfuscationView(icon: .photo)
    
    private var aspectConstraint: NSLayoutConstraint?
    private var cwidthConstraint: NSLayoutConstraint?
    private var cheightConstraint: NSLayoutConstraint?
    
    private var selfLeading: NSLayoutConstraint?
    private var selfTrailing: NSLayoutConstraint?
    private var otherLeading: NSLayoutConstraint?
    private var otherTrailing: NSLayoutConstraint?
    
    
    var containercheightConstraint: NSLayoutConstraint!
    
    weak var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    
    var isSelected: Bool = false
    
    var selectionView: UIView? {
        return containerView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        createConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
 
        messageBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        messageBackgroundView.isUserInteractionEnabled = true
        addSubview(messageBackgroundView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.cornerRadius = 6
        containerView.clipsToBounds = true
        messageBackgroundView.addSubview(containerView)
        
        imageResourceView.contentMode = .scaleAspectFill
        imageResourceView.layer.borderColor = UIColor.from(scheme: .cellSeparator).cgColor
        
        [imageResourceView, obfuscationView].forEach(containerView.addSubview)
        obfuscationView.isHidden = true
    }
    
    private func createConstraints() {
        messageBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        obfuscationView.translatesAutoresizingMaskIntoConstraints = false
        imageResourceView.translatesAutoresizingMaskIntoConstraints = false
        
        obfuscationView.fitInSuperview()
        imageResourceView.fitInSuperview()
        
        containerView.topAnchor.constraint(equalTo: messageBackgroundView.topAnchor, constant: 3).isActive = true
        containerView.leadingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor, constant: 10).isActive = true
        containerView.bottomAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor, constant: -3).isActive = true
        containerView.rightAnchor.constraint(equalTo: messageBackgroundView.rightAnchor, constant: -10).isActive = true
        
        selfLeading = messageBackgroundView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor)
        selfTrailing = messageBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor)
        otherLeading = messageBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor)
        otherTrailing = messageBackgroundView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        
        messageBackgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        messageBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        cwidthConstraint = containerView.widthAnchor.constraint(equalToConstant: 0)
        cheightConstraint = containerView.heightAnchor.constraint(equalToConstant: 0)
        cwidthConstraint?.priority = .defaultHigh
        cheightConstraint?.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            otherLeading!,
            otherTrailing!,
            cwidthConstraint!,
            cheightConstraint!
            ])
    }
    
    func configure(with object: Configuration, animated: Bool) {
        
        let message = object.message
        
        /// messageBackgroundView
        let senderIsSelf = message.sender?.remoteIdentifier == ZMUser.selfUser()?.remoteIdentifier
        if senderIsSelf{
            messageBackgroundView.image = UIImage.init(named: MessageBackImage.mineWithTail.rawValue)
        }else{
            messageBackgroundView.image = UIImage.init(named: MessageBackImage.otherWithTail.rawValue)
        }
        
        /// Leading and Trailing
        if senderIsSelf {
            selfLeading?.isActive = true
            selfTrailing?.isActive = true
            otherLeading?.isActive = false
            otherTrailing?.isActive = false
        }else{
            selfLeading?.isActive = false
            selfTrailing?.isActive = false
            otherLeading?.isActive = true
            otherTrailing?.isActive = true
        }
        
        obfuscationView.isHidden = !object.isObfuscated
        imageResourceView.isHidden = object.isObfuscated
        
        let scaleFactor: CGFloat = object.image.isAnimatedGIF ? 1 : 0.5
        let imageSize = object.image.originalSize.applying(CGAffineTransform.init(scaleX: scaleFactor, y: scaleFactor))
        let imageAspectRatio = imageSize.width > 0 ? imageSize.height / imageSize.width : 1.0
        
        aspectConstraint.apply({ containerView.removeConstraint($0) })
        aspectConstraint = containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: imageAspectRatio)
        aspectConstraint?.isActive = true
        cwidthConstraint?.constant = imageSize.width
        cheightConstraint?.constant = imageSize.height
        
        imageResourceView.layer.borderWidth = 0
        
        let imageResource = object.isObfuscated ? nil : object.image.image
        
        imageResourceView.setImageResource(imageResource) { [weak self] in
            self?.updateImageContainerAppearance()
            _ = object.message.startSelfDestructionIfNeeded()
        }
    }
    
    func updateImageContainerAppearance() {
        if imageResourceView.image?.isTransparent == true {
            imageResourceView.layer.borderWidth = 0
        } else {
            imageResourceView.layer.borderWidth = .hairline
        }
    }
    
}

class ConversationImageMessageCellDescription: ConversationMessageCellDescription {
    
    typealias View = ConversationImageMessageCell
    let configuration: View.Configuration
    
    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 8
    
    let isFullWidth: Bool = false
    let supportsActions: Bool = true
    let containsHighlightableContent: Bool = true
    
    let accessibilityIdentifier: String? = "ImageCell"
    let accessibilityLabel: String? = nil
    
    init(message: ZMConversationMessage, image: ZMImageMessageData) {
        self.message = message
        self.configuration = View.Configuration(image: image, message: message)
    }
    
}
