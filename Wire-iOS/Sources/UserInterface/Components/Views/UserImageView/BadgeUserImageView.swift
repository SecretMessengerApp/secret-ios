
/**
 * A user image view that can display a badge on top for different connection states.
 */

class BadgeUserImageView: UserImageView {

    /// The color of the badge.
    var badgeColor: UIColor = .white {
        didSet {
            updateIconView(with: badgeIcon, animated: false)
        }
    }

    /// The size of the badge icon.
    var badgeIconSize: StyleKitIcon.Size = .tiny {
        didSet {
            updateIconView(with: badgeIcon, animated: false)
        }
    }

    /// The badge icon.
    var badgeIcon: StyleKitIcon? = nil {
        didSet {
            updateIconView(with: badgeIcon, animated: false)
        }
    }

    private let badgeImageView = UIImageView()
    private let badgeShadow = UIView()

    // MARK: - Initialization

    override convenience init(frame: CGRect) {
        self.init(size: .small)
    }
    
    override init(size: UserImageView.Size = .small) {
        super.init(size: size)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureSubviews() {
        isOpaque = false
        container.addSubview(badgeShadow)
        container.addSubview(badgeImageView)
    }

    private func configureConstraints() {
        badgeShadow.translatesAutoresizingMaskIntoConstraints = false
        badgeImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // badgeShadow
            badgeShadow.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            badgeShadow.topAnchor.constraint(equalTo: container.topAnchor),
            badgeShadow.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            badgeShadow.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            // badgeImageView
            badgeImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            badgeImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }

    // MARK: - Updates

    override func updateUser() {
        super.updateUser()
        updateBadgeIcon()
    }

    override func userDidChange(_ changeInfo: UserChangeInfo) {
        super.userDidChange(changeInfo)

        if changeInfo.connectionStateChanged {
            self.updateBadgeIcon()
        }
    }

    /// Updates the badge icon.
    private func updateBadgeIcon() {
        guard let user = self.user?.zmUser else {
            badgeIcon = .none
            return
        }

        if user.isBlocked {
            badgeIcon = .block
        } else if user.isPendingApprovalBySelfUser || user.isPendingApprovalByOtherUser {
            badgeIcon = .clock
        } else {
            badgeIcon = .none
        }
    }

    // MARK: - Interface

    /**
     * Updates the icon view with the specified icon, with an optional animation.
     * - parameter icon: The icon to show on the badge.
     * - parameter animated: Whether to animate the change.
     */

    func updateIconView(with icon: StyleKitIcon?, animated: Bool) {
        badgeImageView.image = nil

        if let icon = icon {
            let hideBadge = {
                self.badgeImageView.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
                self.badgeImageView.alpha = 0
            }

            let changeImage = {
                self.badgeImageView.setIcon(icon,
                                                    size: self.badgeIconSize,
                                                    color: self.badgeColor)
            }

            let showBadge = {
                self.badgeImageView.transform = .identity
                self.badgeImageView.alpha = 1
            }

            let showShadow = {
                self.badgeShadow.backgroundColor = UIColor(white: 0, alpha: 0.5)
            }

            if animated {
                hideBadge()
                changeImage()
                UIView.animate(withDuration: 0.65, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 15.0, options: [], animations: showBadge, completion: nil)
                UIView.animate(easing: .easeOutQuart, duration: 0.15, animations: showShadow)
            } else {
                changeImage()
                showShadow()
            }

        } else {
            badgeShadow.backgroundColor = .clear
        }
    }

}

// MARK: - Compatibility

extension BadgeUserImageView {

    var wr_badgeIconSize: CGFloat {
        get {
            return badgeIconSize.rawValue
        }
        set {
            badgeIconSize = .custom(newValue)
        }
    }

    func setBadgeIcon(_ newValue: StyleKitIcon) {
        badgeIcon = newValue
    }

    func removeBadgeIcon() {
        badgeIcon = nil
    }

}
