
import UIKit

class ConversationSenderMessageCell: UIView, ConversationMessageCell {
    
    struct Configuration {
        let user: UserType
        let message: ZMConversationMessage
        let indicatorIcon: UIImage?
    }
    
    weak var delegate: ConversationMessageCellDelegate? = nil
    weak var message: ZMConversationMessage? = nil
    
    var isSelected: Bool = false
    
    private let senderView = SenderCellComponent()
    private let indicatorImageView = ThemedImageView()
    
    private var indicatorImageViewTrailing: NSLayoutConstraint!
    
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
    
    func configure(with object: Configuration, animated: Bool) {
        senderView.configure(with: object.user, conversation: object.message.conversation)
        indicatorImageView.isHidden = object.indicatorIcon == nil
        indicatorImageView.image = object.indicatorIcon?.withColor(.dynamic(scheme: .iconNormal))
    }
    
    private func configureSubviews() {
        addSubview(senderView)
        addSubview(indicatorImageView)
//        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOnAvatar)))
        senderView.avatar.addTarget(self, action:  #selector(tappedOnAvatar), for: .touchUpInside)
        let longPressGr = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnAvatar))
        //        longPressGr.minimumPressDuration = 3.0
        senderView.avatar.addGestureRecognizer(longPressGr)
    }
    
    private func configureConstraints() {
        senderView.translatesAutoresizingMaskIntoConstraints = false
        indicatorImageView.translatesAutoresizingMaskIntoConstraints = false

        indicatorImageViewTrailing = indicatorImageView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -conversationHorizontalMargins.right)

        NSLayoutConstraint.activate([
            // indicatorImageView
            indicatorImageViewTrailing,
            indicatorImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // senderView
            senderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            senderView.topAnchor.constraint(equalTo: topAnchor),
            senderView.trailingAnchor.constraint(equalTo: indicatorImageView.leadingAnchor, constant: -8),
            senderView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        indicatorImageViewTrailing.constant = -conversationHorizontalMargins.right
    }
    
    @objc private func tappedOnAvatar() {
        guard let user = senderView.avatar.user else { return }
        delegate?.conversationMessageWantsToOpenUserDetails(self, user: user, sourceView: senderView, frame: selectionRect)
    }
    
    @objc private func longPressOnAvatar(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else {
            return
        }
        guard let user = senderView.avatar.user else { return }
        delegate?.conversationCellWantsToMention?(user: user)
    }
    
}

class ConversationSenderMessageCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationSenderMessageCell
    let configuration: View.Configuration
    
    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 16
    
    let isFullWidth: Bool = true
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = false
    
    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil
    
    init(sender: UserType, message: ZMConversationMessage) {
        self.message = message
        
        var icon: UIImage? = nil
        let iconColor = UIColor.from(scheme: .iconNormal)
        
        if message.isDeletion {
            icon = StyleKitIcon.trash.makeImage(size: 8, color: iconColor)
        } else if message.updatedAt != nil {
            icon = StyleKitIcon.pencil.makeImage(size: 8, color: iconColor)
        }
        
        self.configuration = View.Configuration(user: sender, message: message, indicatorIcon: icon)
        actionController = nil
    }
    
}
