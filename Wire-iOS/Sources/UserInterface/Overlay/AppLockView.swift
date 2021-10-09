
import Foundation

final class AppLockView: UIView {
    public var onReauthRequested: (()->())?
    
    public let shieldViewContainer = UIView()
    public let contentContainerView = UIView()
    public let blurView: UIVisualEffectView!
    public let authenticateLabel: UILabel = {
        let label = UILabel()
        label.font = .largeThinFont
        label.textColor = .from(scheme: .textForeground, variant: .dark)
        return label
    }()
    public let authenticateButton = Button(style: .fullMonochrome)
    
    private var contentWidthConstraint: NSLayoutConstraint!
    private var contentCenterConstraint: NSLayoutConstraint!
    private var contentLeadingConstraint: NSLayoutConstraint!
    private var contentTrailingConstraint: NSLayoutConstraint!

    var userInterfaceSizeClass :(UITraitEnvironment) -> UIUserInterfaceSizeClass = {traitEnvironment in
        return traitEnvironment.traitCollection.horizontalSizeClass
    }

    public var showReauth: Bool = false {
        didSet {
            self.authenticateLabel.isHidden = !showReauth
            self.authenticateButton.isHidden = !showReauth
        }
    }

    init(authenticationType: AuthenticationType = .current) {
        let blurEffect = UIBlurEffect(style: .dark)
        self.blurView = UIVisualEffectView(effect: blurEffect)
        
        super.init(frame: .zero)
        
        let loadedObjects = UINib(nibName: "LaunchScreen", bundle: nil).instantiate(withOwner: .none, options: .none)
        
        let nibView = loadedObjects.first as! UIView
        shieldViewContainer.addSubview(nibView)

        addSubview(shieldViewContainer)
        addSubview(blurView)
        
        self.authenticateLabel.isHidden = true
        self.authenticateLabel.numberOfLines = 0
        self.authenticateButton.isHidden = true
        
        addSubview(contentContainerView)
        
        contentContainerView.addSubview(authenticateLabel)
        contentContainerView.addSubview(authenticateButton)

        switch authenticationType {
        case .touchID:
            self.authenticateLabel.text = "self.settings.privacy_security.lock_cancelled.description_touch_id".localized
        case .faceID:
            self.authenticateLabel.text = "self.settings.privacy_security.lock_cancelled.description_face_id".localized
        case .passcode:
            self.authenticateLabel.text = "self.settings.privacy_security.lock_cancelled.description_passcode".localized
        case .unavailable:
            self.authenticateLabel.text = "self.settings.privacy_security.lock_cancelled.description_passcode_unavailable".localized
        }

        self.authenticateButton.setTitle("self.settings.privacy_security.lock_cancelled.action".localized, for: .normal)
        self.authenticateButton.addTarget(self, action: #selector(AppLockView.onReauthenticatePressed(_:)), for: .touchUpInside)

        createConstraints(nibView: nibView)

        toggleConstraints()
    }

    private func createConstraints(nibView: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        nibView.translatesAutoresizingMaskIntoConstraints = false
        shieldViewContainer.translatesAutoresizingMaskIntoConstraints = false
        blurView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        authenticateButton.translatesAutoresizingMaskIntoConstraints = false
        authenticateLabel.translatesAutoresizingMaskIntoConstraints = false

        // Compact
        contentLeadingConstraint = contentContainerView.leadingAnchor.constraint(equalTo: leadingAnchor)
        contentTrailingConstraint = contentContainerView.trailingAnchor.constraint(equalTo: trailingAnchor)

        // Regular
        contentCenterConstraint = contentContainerView.centerXAnchor.constraint(equalTo: centerXAnchor)
        contentWidthConstraint = contentContainerView.widthAnchor.constraint(equalToConstant: 320)

        NSLayoutConstraint.activate([
            // nibView
            nibView.leadingAnchor.constraint(equalTo: leadingAnchor),
            nibView.topAnchor.constraint(equalTo: topAnchor),
            nibView.trailingAnchor.constraint(equalTo: trailingAnchor),
            nibView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // shieldViewContainer
            shieldViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            shieldViewContainer.topAnchor.constraint(equalTo: topAnchor),
            shieldViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            shieldViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

            // blurView
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // contentContainerView
            contentContainerView.topAnchor.constraint(equalTo: topAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // authenticateLabel
            authenticateLabel.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 24),
            authenticateLabel.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -24),

            // authenticateButton
            authenticateButton.heightAnchor.constraint(equalToConstant: 40),
            authenticateButton.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 24),
            authenticateButton.topAnchor.constraint(equalTo: authenticateLabel.bottomAnchor, constant: 24),
            authenticateButton.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -24),
            authenticateButton.bottomAnchor.constraint(equalTo: contentContainerView.safeBottomAnchor, constant: -24),
        ])
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        toggleConstraints()
    }

    
    func toggleConstraints() {
        userInterfaceSizeClass(self).toggle(compactConstraints: [contentLeadingConstraint, contentTrailingConstraint],
               regularConstraints: [contentCenterConstraint, contentWidthConstraint])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatal("init(coder) is not implemented")
    }
    
    @objc public func onReauthenticatePressed(_ sender: AnyObject!) {
        self.onReauthRequested?()
    }
}
