
import Foundation
import Cartography

class StartUIIconCell: UICollectionViewCell {
    
    fileprivate let iconView = UIImageView()
    fileprivate let titleLabel = UILabel()
    fileprivate let separator = UIView()
    
    var icon: StyleKitIcon? {
        didSet {
            iconView.image = icon?.makeImage(size: .tiny, color: .dynamic(scheme: .title))
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.dynamic(scheme: .cellSelectedBackground) : .clear
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        iconView.contentMode = .center
        titleLabel.font = FontSpec(.normal, .light).font
        titleLabel.textColor = .dynamic(scheme: .title)
        [iconView, titleLabel, separator].forEach(contentView.addSubview)
        separator.backgroundColor = UIColor.dynamic(scheme: .separator)
    }
    
    fileprivate  func createConstraints() {
        let iconSize: CGFloat = 32.0
        
        constrain(contentView, iconView, titleLabel, separator) { container, iconView, titleLabel, separator in
            iconView.width == iconSize
            iconView.height == iconSize
            iconView.leading == container.leading + 16
            iconView.centerY == container.centerY
            
            titleLabel.leading == container.leading + 64
            titleLabel.trailing == container.trailing
            titleLabel.top == container.top
            titleLabel.bottom == container.bottom
            
            separator.leading == titleLabel.leading
            separator.trailing == container.trailing
            separator.bottom == container.bottom
            separator.height == .hairline
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        iconView.image = icon?.makeImage(size: .tiny, color: .dynamic(scheme: .title))
    }
}

final class InviteTeamMemberCell: StartUIIconCell  {
    
    override func setupViews() {
        super.setupViews()
        icon = .envelope
        title = "peoplepicker.invite_team_members".localized
        isAccessibilityElement = true
        accessibilityLabel = title
        accessibilityTraits.insert(.button)
        accessibilityIdentifier = "button.searchui.invite_team"
    }
    
}

final class AddFriendCell: StartUIIconCell  {
    
    override func setupViews() {
        super.setupViews()
        icon = .addFriend
        title = "conversation_list.popover.add_friend".localized
        isAccessibilityElement = true
        accessibilityLabel = title
        accessibilityIdentifier = "button.searchui.addfriend"
    }
}

final class CreateGroupCell: StartUIIconCell  {
    
    override func setupViews() {
        super.setupViews()
        icon = .makeConversation
        title = "peoplepicker.quick-action.create-conversation".localized
        isAccessibilityElement = true
        accessibilityLabel = title
        accessibilityTraits.insert(.button)
        accessibilityIdentifier = "button.searchui.creategroup"
    }
}

final class CreateHugeGroupCell: StartUIIconCell  {
    
    override func setupViews() {
        super.setupViews()
        icon = .createConversation
        title = "peoplepicker.quick-action.create-hugegroup".localized
        isAccessibilityElement = true
        accessibilityLabel = title
        accessibilityIdentifier = "button.searchui.createhugegroup"
    }
}

final class CreateGuestRoomCell: StartUIIconCell  {
    
    override func setupViews() {
        super.setupViews()
        icon = .guest
        title = "peoplepicker.quick-action.create-guest-room".localized
        isAccessibilityElement = true
        accessibilityLabel = title
        accessibilityTraits.insert(.button)
        accessibilityIdentifier = "button.searchui.createguestroom"
    }
    
}

final class InviteContactCell: StartUIIconCell  {
    
    override func setupViews() {
        super.setupViews()
        icon = .addressBook
        title = "peoplepicker.quick-action.invite-addressbook".localized
        isAccessibilityElement = true
        accessibilityLabel = title
        accessibilityIdentifier = "button.searchui.invite-addressbook"
    }
}

final class OpenServicesAdminCell: StartUIIconCell, Themeable  {
    @objc dynamic var colorSchemeVariant: ColorSchemeVariant = ColorScheme.default.variant {
        didSet {
            guard oldValue != colorSchemeVariant else { return }
            applyColorScheme(colorSchemeVariant)
        }
    }
    
    @objc dynamic var contentBackgroundColor: UIColor? = nil {
        didSet {
            guard oldValue != contentBackgroundColor else { return }
            applyColorScheme(colorSchemeVariant)
        }
    }
    
    func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        backgroundColor = UIColor.dynamic(scheme: .background)
        separator.backgroundColor = UIColor.dynamic(scheme: .separator)
        titleLabel.textColor = UIColor.dynamic(scheme: .title)
        iconView.image = icon?.makeImage(size: .tiny, color: UIColor.dynamic(scheme: .title))
    }
    
    func contentBackgroundColor(for colorSchemeVariant: ColorSchemeVariant) -> UIColor {
        return contentBackgroundColor ?? UIColor.dynamic(scheme: .cellBackground)
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted
                ? UIColor(white: 0, alpha: 0.08)
                : contentBackgroundColor(for: colorSchemeVariant)
        }
    }
    
    override func setupViews() {
        super.setupViews()
        icon = .bot
        title = "peoplepicker.quick-action.admin-services".localized
        isAccessibilityElement = true
        accessibilityLabel = title
        accessibilityIdentifier = "button.searchui.open-services"
        applyColorScheme(ColorScheme.default.variant)
    }
    
}
