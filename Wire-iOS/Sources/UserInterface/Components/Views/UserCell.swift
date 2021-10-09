
import UIKit


class UserCell: SeparatorCollectionViewCell {

    var hidesSubtitle: Bool = false
    
    let avatarSpacer = UIView()
    let avatar = BadgeUserImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let connectButton = IconButton()
    let accessoryIconView = ThemedImageView()
    let guestIconLabel = UILabel()
    let verifiedIconView = UIImageView()
    let videoIconView = UIImageView()
    let checkmarkIconView = UIImageView()
    var contentStackView : UIStackView!
    var titleStackView : UIStackView!
    var iconStackView : UIStackView!
    
    fileprivate var avatarSpacerWidthConstraint: NSLayoutConstraint?
    
    weak var user: UserType? = nil
    weak var conversation: ZMConversation? = nil
    
    static let boldFont: UIFont = .smallRegularFont
    static let lightFont: UIFont = .smallLightFont
    static let defaultAvatarSpacing: CGFloat = 64
    
    /// Specify a custom avatar spacing
    var avatarSpacing: CGFloat? {
        get {
            return avatarSpacerWidthConstraint?.constant
        }
        set {
            avatarSpacerWidthConstraint?.constant = newValue ?? UserCell.defaultAvatarSpacing
        }
    }

    override var isSelected: Bool {
        didSet {
            let foregroundColor = UIColor.from(scheme: .background, variant: colorSchemeVariant)
            let backgroundColor = UIColor.from(scheme: .iconNormal, variant: colorSchemeVariant)
            let borderColor = isSelected ? backgroundColor : backgroundColor.withAlphaComponent(0.64)
            checkmarkIconView.image = isSelected ? StyleKitIcon.checkmark.makeImage(size: 12, color: foregroundColor) : nil
            checkmarkIconView.backgroundColor = isSelected ? backgroundColor : .clear
            checkmarkIconView.layer.borderColor = borderColor.cgColor
        }
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        UIView.performWithoutAnimation {
            hidesSubtitle = false
            verifiedIconView.isHidden = true
            videoIconView.isHidden = true
            connectButton.isHidden = true
            accessoryIconView.isHidden = true
            checkmarkIconView.image = nil
            checkmarkIconView.layer.borderColor = UIColor.from(scheme: .iconNormal, variant: colorSchemeVariant).cgColor
            checkmarkIconView.isHidden = true
        }
    }
    
    override func setUp() {
        super.setUp()

        guestIconLabel.translatesAutoresizingMaskIntoConstraints = false
        guestIconLabel.contentMode = .center
        guestIconLabel.accessibilityIdentifier = "label.guest"
        guestIconLabel.isHidden = true
        guestIconLabel.textColor = UIColor.dynamic(scheme: .subtitle)
        guestIconLabel.font = UIFont(13, .regular)
        
        videoIconView.translatesAutoresizingMaskIntoConstraints = false
        videoIconView.contentMode = .center
        videoIconView.accessibilityIdentifier = "img.video"
        videoIconView.isHidden = true
        
        verifiedIconView.image = WireStyleKit.imageOfShieldverified
        verifiedIconView.translatesAutoresizingMaskIntoConstraints = false
        verifiedIconView.contentMode = .center
        verifiedIconView.accessibilityIdentifier = "img.shield"
        verifiedIconView.isHidden = true
        
        connectButton.setIcon(.plusCircled, size: .tiny, for: .normal)
        connectButton.setIconColor(scheme: .iconNormal, for: .normal)
        connectButton.imageView?.contentMode = .center
        connectButton.isHidden = true
        
        checkmarkIconView.layer.borderWidth = 2
        checkmarkIconView.contentMode = .center
        checkmarkIconView.layer.cornerRadius = 12
        checkmarkIconView.isHidden = true

        accessoryIconView.translatesAutoresizingMaskIntoConstraints = false
        accessoryIconView.contentMode = .center
        accessoryIconView.isHidden = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .normalLightFont
        titleLabel.accessibilityIdentifier = "user_cell.name"
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .smallRegularFont
        subtitleLabel.accessibilityIdentifier = "user_cell.username"
        
        avatar.userSession = ZMUserSession.shared()
        avatar.initialsFont = .avatarInitial
        avatar.size = .small
        avatar.translatesAutoresizingMaskIntoConstraints = false

        avatarSpacer.addSubview(avatar)
        avatarSpacer.translatesAutoresizingMaskIntoConstraints = false
        
        iconStackView = UIStackView(arrangedSubviews: [verifiedIconView, guestIconLabel, videoIconView, connectButton, checkmarkIconView, accessoryIconView])
        iconStackView.spacing = 16
        iconStackView.axis = .horizontal
        iconStackView.distribution = .fill
        iconStackView.alignment = .center
        iconStackView.translatesAutoresizingMaskIntoConstraints = false
        iconStackView.setContentHuggingPriority(.required, for: .horizontal)
        
        titleStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStackView.axis = .vertical
        titleStackView.distribution = .equalSpacing
        titleStackView.alignment = .leading
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView = UIStackView(arrangedSubviews: [avatarSpacer, titleStackView, iconStackView])
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.alignment = .center
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(contentStackView)
        createConstraints()
    }
    
    func createConstraints() {
        let avatarSpacerWidthConstraint = avatarSpacer.widthAnchor.constraint(equalToConstant: UserCell.defaultAvatarSpacing)
        self.avatarSpacerWidthConstraint = avatarSpacerWidthConstraint
        
        NSLayoutConstraint.activate([
            checkmarkIconView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkIconView.heightAnchor.constraint(equalToConstant: 24),
            avatar.widthAnchor.constraint(equalToConstant: 38),
            avatar.heightAnchor.constraint(equalToConstant: 38),
            avatarSpacerWidthConstraint,
            avatarSpacer.heightAnchor.constraint(equalTo: avatar.heightAnchor),
            avatarSpacer.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            avatarSpacer.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        
        videoIconView.setIcon(.videoCall, size: .tiny, color: UIColor.from(scheme: .iconGuest, variant: colorSchemeVariant))
        //guestIconView.setIcon(.guest, size: .tiny, color: UIColor.from(scheme: .iconGuest, variant: colorSchemeVariant))
        accessoryIconView.setIcon(.disclosureIndicator, size: 12, color: .dynamic(scheme: .accessory))

        checkmarkIconView.layer.borderColor = UIColor.from(scheme: .iconNormal, variant: colorSchemeVariant).cgColor
        titleLabel.textColor = .dynamic(scheme: .title)
        subtitleLabel.textColor = .dynamic(scheme: .subtitle)
        updateTitleLabel()
    }
    
    private func updateTitleLabel() {
        guard let user = self.user else {
            return
        }
        
        var attributedTitle: NSAttributedString?
        
        attributedTitle = NSAttributedString(string: user.displayName(in: conversation))
        
        if let muser = user as? ZMUser, let remark = muser.reMark {
            attributedTitle = NSAttributedString(string: remark + " (" + (user.name ?? "") + ")")
        }
        
        
//        if user.isSelfUser, let title = attributedTitle {
//            attributedTitle = title + "user_cell.title.you_suffix".localized
//        }
        titleLabel.attributedText = attributedTitle
    }
    
    public func configure(with user: UserType, conversation: ZMConversation? = nil) {
        configure(with: user, subtitle: subtitle(for: user), conversation: conversation)
    }
    

    public func configure(with handle: String, name: String) {
        self.user = nil
        self.conversation = nil
        titleLabel.attributedText = NSAttributedString(string: name)
        guestIconLabel.isHidden = true
        guestIconLabel.text = ""
        verifiedIconView.isHidden  = true
        subtitleLabel.isHidden = false
        subtitleLabel.text = "@" + handle
    }

    public func configure(with user: UserType, subtitle: NSAttributedString?, conversation: ZMConversation? = nil) {
        self.user = user
        self.conversation = conversation
        avatar.user = user
        updateTitleLabel()

        configureguestIconLabel(user: user, conversation: conversation)
//        if let conversation = conversation {
//            guestIconLabel.isHidden = !user.isGuest(in: conversation)
//        } else {
//            guestIconLabel.isHidden = !ZMUser.selfUser().isTeamMember || user.isTeamMember || user.isServiceUser
//        }

        if let user = user as? ZMUser {
            verifiedIconView.isHidden = !user.trusted() || user.clients.isEmpty
        } else {
            verifiedIconView.isHidden  = true
        }

        if let subtitle = subtitle, !subtitle.string.isEmpty, !hidesSubtitle {
            subtitleLabel.isHidden = false
            subtitleLabel.attributedText = subtitle
        } else {
            subtitleLabel.isHidden = true
        }
    }
    

    private func configureguestIconLabel(user: UserType, conversation: ZMConversation?) {
        if let conversation = conversation {
            
            func adapt(statement: (isCreator: Bool, isSelfUser: Bool, isManager: Bool)) -> String? {
                switch statement {
                case (true, true, _):
                    return "participants.avatar.host.title".localized + " & " + "participants.avatar.me.title".localized
                case (true, false, _):
                    return "participants.avatar.host.title".localized
                case (_, false , true):
                    return "participants.avatar.manager.title".localized
                case (_, true , true):
                    return "participants.avatar.manager.title".localized + " & " +    "participants.avatar.me.title".localized
                case (_, true , false):
                    return "participants.avatar.me.title".localized
                default:
                    return nil
                }
            }
            
            var statement: (isCreator: Bool, isSelfUser: Bool, isManager: Bool) = (false, false, false)
            if let u = user as? ZMUser {
                statement = (conversation.creator == u,
                             u.isSelfUser,
                             conversation.manager?.contains(user.zmUser?.remoteIdentifier.transportString() ?? "") ?? false)
                
            }
            if let u = user as? ConversationBGPMemberModel { 
                statement = (conversation.creator.remoteIdentifier.transportString() == u.id,
                             ZMUser.selfUser()?.remoteIdentifier.transportString() == u.id,
                             conversation.manager?.contains(u.id) ?? false)
            }
            if let text = adapt(statement: statement) {
                guestIconLabel.isHidden = false
                guestIconLabel.text = text
            } else {
                guestIconLabel.isHidden = true
            }
        } else {
            guestIconLabel.isHidden = !ZMUser.selfUser().isTeamMember || user.isTeamMember || user.isServiceUser
        }
    }

}

// MARK: - Subtitle

extension UserCell: UserCellSubtitleProtocol {}

extension UserCell {
    
    func subtitle(for user: UserType) -> NSAttributedString? {
        if user.isServiceUser, let service = user as? SearchServiceUser {
            return subtitle(forServiceUser: service)
        } else {
            return subtitle(forRegularUser: user)
        }
    }

    private func subtitle(forServiceUser service: SearchServiceUser) -> NSAttributedString? {
        guard let summary = service.summary else { return nil }
        
        return summary && UserCell.boldFont
    }

    static var correlationFormatters:  [ColorSchemeVariant : AddressBookCorrelationFormatter] = [:]
}

// MARK: - Availability

extension UserType {
    
    func nameIncludingAvailability(color: UIColor, conversation: ZMConversation? = nil) -> NSAttributedString? {
        if ZMUser.selfUser().isTeamMember, let user = self as? ZMUser {
            return AvailabilityStringBuilder.string(for: user, with: .list, color: color)
        } else {
            return NSAttributedString(string: displayName(in: conversation))
        }
    }
    
}
