
import Foundation

class GroupConversationCell: UICollectionViewCell, Themeable {
    
    let avatarSpacer = UIView()
    let avatarView = ConversationAvatarView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let separator = UIView()
    var contentStackView : UIStackView!
    var titleStackView : UIStackView!
    
    @objc dynamic var colorSchemeVariant: ColorSchemeVariant = ColorScheme.default.variant {
        didSet {
            guard oldValue != colorSchemeVariant else { return }
            applyColorScheme(colorSchemeVariant)
        }
    }
    
    // if nil the background color is the default content background color for the theme
    @objc dynamic var contentBackgroundColor: UIColor? = nil {
        didSet {
            guard oldValue != contentBackgroundColor else { return }
            applyColorScheme(colorSchemeVariant)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .init(white: 0, alpha: 0.08) : .clear
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func contentBackgroundColor(for colorSchemeVariant: ColorSchemeVariant) -> UIColor {
        return contentBackgroundColor ?? UIColor.dynamic(scheme: .cellBackground)
    }
    
    fileprivate func setup() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = FontSpec.init(.normal, .light).font!
        titleLabel.accessibilityIdentifier = "user_cell.name"
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = FontSpec.init(.small, .regular).font!
        subtitleLabel.accessibilityIdentifier = "user_cell.username"
        
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        
        avatarSpacer.addSubview(avatarView)
        avatarSpacer.translatesAutoresizingMaskIntoConstraints = false

        titleStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStackView.axis = .vertical
        titleStackView.distribution = .equalSpacing
        titleStackView.alignment = .leading
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView = UIStackView(arrangedSubviews: [avatarSpacer, titleStackView])
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.alignment = .center
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(contentStackView)
        contentView.addSubview(separator)
        
        applyColorScheme(colorSchemeVariant)
        createConstraints()
    }
    
    func createConstraints() {
        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: 28),
            avatarView.heightAnchor.constraint(equalToConstant: 28),
            avatarSpacer.widthAnchor.constraint(equalToConstant: 64),
            avatarSpacer.heightAnchor.constraint(equalTo: avatarView.heightAnchor),
            avatarSpacer.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarSpacer.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 64),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: .hairline),
        ])
    }
    
    func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        let sectionTextColor = UIColor.dynamic(scheme: .title)
        backgroundColor = UIColor.dynamic(scheme: .background)
        separator.backgroundColor = UIColor.dynamic(scheme: .separator)
        titleLabel.textColor = UIColor.dynamic(scheme: .title)
        subtitleLabel.textColor = sectionTextColor
    }
    
    public func configure(conversation: ZMConversation) {
        avatarView.configure(context: .conversation(conversation: conversation))

        titleLabel.text = conversation.displayName
        
        if conversation.conversationType == .oneOnOne, let handle = conversation.connectedUser?.handle {
            subtitleLabel.isHidden = false
            subtitleLabel.text = "@\(handle)"
        } else {
            subtitleLabel.isHidden = true
        }
    }
    
}
