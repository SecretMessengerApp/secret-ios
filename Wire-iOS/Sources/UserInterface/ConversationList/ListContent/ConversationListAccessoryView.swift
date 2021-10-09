
import UIKit

final class ConversationListAccessoryView: UIView {
    var conversation: ZMConversation?
    var icon: ConversationStatusIcon? = nil {
        didSet {
            if icon != oldValue {
                updateForIcon()
            }

            if icon == nil {
                accessibilityValue = nil
            }
        }
    }
    
    var activeMediaPlayer: MediaPlayer? {
        let mediaManager = mediaPlaybackManager ?? AppDelegate.shared.mediaPlaybackManager
        return mediaManager?.activeMediaPlayer
    }
    
    let mediaPlaybackManager: MediaPlaybackManager?
    let dragableRedDot = DragableRedDot()
    let badgeView = RoundedBadge(view: UIView())
    let transparentIconView = UIImageView()
    let textLabel = UILabel()
    let iconView = UIImageView()
    var collapseWidthConstraint: NSLayoutConstraint!
    var expandWidthConstraint: NSLayoutConstraint!
    var expandTransparentIconViewWidthConstraint: NSLayoutConstraint!
    let defaultViewWidth: CGFloat = 28
    let activeCallWidth: CGFloat = 20
    
    init(mediaPlaybackManager: MediaPlaybackManager? = nil) {
        self.mediaPlaybackManager = mediaPlaybackManager
        super.init(frame: .zero)
        
        badgeView.accessibilityIdentifier = "action_button"
                
        textLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        textLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .vertical)
        textLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        textLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        textLabel.textAlignment = .center
        textLabel.font = FontSpec(.medium, .semibold).font!
        
        transparentIconView.contentMode = .center
        transparentIconView.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        transparentIconView.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        transparentIconView.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        transparentIconView.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .vertical)
        
        iconView.contentMode = .center
        iconView.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        iconView.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        iconView.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        iconView.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .vertical)
        
        [badgeView, transparentIconView].forEach(addSubview)

        createConstraints()
        updateForIcon()
        
        dragableRedDot.attach(item: badgeView) { [weak self] (view) -> Bool in
            self?.conversation?.markAsRead()
            return true
        }
    }

    func createConstraints() {
        transparentIconView.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false

        let transparentIconViewLeading = transparentIconView.leadingAnchor.constraint(equalTo: leadingAnchor)
        transparentIconViewLeading.priority = UILayoutPriority(999.0)

        let transparentIconViewTrailing = transparentIconView.trailingAnchor.constraint(equalTo: trailingAnchor)
        transparentIconViewTrailing.priority = UILayoutPriority(999.0)

        expandTransparentIconViewWidthConstraint = transparentIconView.widthAnchor.constraint(greaterThanOrEqualToConstant: defaultViewWidth)

        expandWidthConstraint = widthAnchor.constraint(greaterThanOrEqualToConstant: defaultViewWidth)

        // collapseWidthConstraint is inactive when init, it is toggled in updateCollapseConstraints()
        collapseWidthConstraint = widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            badgeView.heightAnchor.constraint(equalToConstant: 20),
            transparentIconViewLeading,
            transparentIconViewTrailing,
            expandTransparentIconViewWidthConstraint,
            expandWidthConstraint
            ] +
            transparentIconView.topAndBottomEdgesToSuperviewEdges()
        )
        badgeView.fitInSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var viewForState: UIView? {
        let iconSize: StyleKitIcon.Size = 12
        
        guard let icon = icon else { return nil }
        
        switch icon {
        case .pendingConnection:
            iconView.setIcon(.clock, size: iconSize, color: .white)
            accessibilityValue = "conversation_list.voiceover.status.pending_connection".localized
            return iconView
        case .activeCall(false):
            accessibilityValue = "conversation_list.voiceover.status.active_call".localized
            return .none
        case .activeCall(true):
            textLabel.text = "conversation_list.right_accessory.join_button.title".localized(uppercased: true)
            accessibilityValue = textLabel.text
            return textLabel
        case .missedCall:
            iconView.setIcon(.endCall, size: iconSize, color: .white)
            accessibilityValue = "conversation_list.voiceover.status.missed_call".localized
            return iconView
        case .playingMedia:
            if let mediaPlayer = activeMediaPlayer, mediaPlayer.state == .playing {
                iconView.setIcon(.pause, size: iconSize, color: .white)
                accessibilityValue = "conversation_list.voiceover.status.pause_media".localized
            }
            else {
                iconView.setIcon(.play, size: iconSize, color: .white)
                accessibilityValue = "conversation_list.voiceover.status.play_media".localized
            }
            return iconView
        case .silenced:
            iconView.setIcon(.bellWithStrikethrough, size: iconSize, color: .dynamic(scheme: .silenced))
            accessibilityValue = "conversation_list.voiceover.status.silenced".localized
            return iconView
        case .typing:
            accessibilityValue = "conversation_list.voiceover.status.typing".localized
            return .none
        case .unreadMessages(let count):
            textLabel.text = String(count)
            accessibilityValue = textLabel.text
            return textLabel
        case .mention:
            iconView.setIcon(.mention, size: iconSize, color: .white)
            accessibilityValue = "conversation_list.voiceover.status.mention".localized
            return iconView
        case .reply:
            iconView.setIcon(.reply, size: iconSize, color: .white)
            accessibilityValue = "conversation_list.voiceover.status.reply".localized
            return iconView
        case .unreadPing:
            iconView.setIcon(.ping, size: iconSize, color: .dynamic(scheme: .unreadPing))
            accessibilityValue = "conversation_list.voiceover.status.ping".localized
            return iconView
        }
    }

    func updateCollapseConstraints(isCollapsed: Bool) {
        if isCollapsed {
            badgeView.updateCollapseConstraints(isCollapsed: isCollapsed)
            expandWidthConstraint.isActive = false
            expandTransparentIconViewWidthConstraint.isActive = false
            collapseWidthConstraint.isActive = true
        } else {
            collapseWidthConstraint.isActive = false
            expandWidthConstraint.isActive = true
            expandTransparentIconViewWidthConstraint.isActive = true
            badgeView.updateCollapseConstraints(isCollapsed: isCollapsed)
        }
    }
    
    func updateForIcon() {
        self.badgeView.containedView.subviews.forEach { $0.removeFromSuperview() }
        self.badgeView.backgroundColor = .dynamic(scheme: .badgeBackground)
        
        self.badgeView.isHidden = false
        self.transparentIconView.isHidden = true
        
        self.expandTransparentIconViewWidthConstraint.constant = defaultViewWidth
        self.expandWidthConstraint.constant = defaultViewWidth
        
        if case .activeCall(true) = self.icon {
            self.textLabel.textColor = .white
        } else {
            self.textLabel.textColor = .dynamic(scheme: .title)
        }
        
        guard let icon = icon else {
            self.badgeView.isHidden = true
            self.transparentIconView.isHidden = true
            
            updateCollapseConstraints(isCollapsed: true)
            return
        }
        self.badgeView.isUserInteractionEnabled = false 
        switch icon {
        case .activeCall(false):
            self.badgeView.isHidden = true
            self.transparentIconView.isHidden = false
            self.transparentIconView.setIcon(.phone, size: 18, color: .dynamic(scheme: .activeCall))
            
            self.expandTransparentIconViewWidthConstraint.constant = activeCallWidth
            self.expandWidthConstraint.constant = activeCallWidth

        case .activeCall(true): // "Join" button
            self.badgeView.backgroundColor = .strongLimeGreen
            
        case .typing:
            self.badgeView.isHidden = true
            self.transparentIconView.isHidden = false
            self.transparentIconView.setIcon(.pencil, size: 12, color: .dynamic(scheme: .subtitle))
            
        case .unreadMessages(_), .mention:
            self.textLabel.textColor = UIColor.from(scheme: .textForeground, variant: .dark)
            self.badgeView.backgroundColor = .vividRed
            self.badgeView.isUserInteractionEnabled = true
        case .unreadPing:
            self.badgeView.backgroundColor = .dynamic(scheme: .badgeBackground)
            
        case .missedCall:
            self.badgeView.backgroundColor = .vividRed
            
        case .reply:
            self.badgeView.backgroundColor = .dynamic(scheme: .brand)
            
        default:
            self.transparentIconView.image = .none
        }
        
        updateCollapseConstraints(isCollapsed: false)

        if let view = self.viewForState {
            self.badgeView.containedView.addSubview(view)

            let parentView = self.badgeView.containedView
            view.translatesAutoresizingMaskIntoConstraints = false
            parentView.translatesAutoresizingMaskIntoConstraints = false
            view.setContentCompressionResistancePriority(.required, for: .horizontal)
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: parentView.topAnchor),
                view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
                view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 6),
                view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -6)
                ])

        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateForIcon()
    }
}
