
import UIKit
import Cartography

@objc protocol LandingViewControllerDelegate {
    func landingViewControllerDidChooseCreateAccount()
    func landingViewControllerDidChooseCreateTeam()
    func landingViewControllerDidChooseLogin()
}

extension Notification.Name {
    static let guideStartUsingNotificationName = Notification.Name("GuideStartUsingNotificationName")
}

/// Landing screen for choosing how to authenticate.
class LandingViewController: AuthenticationStepViewController {

    // MARK: - State

    weak var authenticationCoordinator: AuthenticationCoordinator?

    var delegate: LandingViewControllerDelegate? {
        return authenticationCoordinator
    }

    // MARK: - UI Styles

    static let semiboldFont = FontSpec(.large, .semibold).font!
    static let regularFont = FontSpec(.normal, .regular).font!

    static let buttonTitleAttribute: [NSAttributedString.Key: AnyObject] = {
        let alignCenterStyle = NSMutableParagraphStyle()
        alignCenterStyle.alignment = .center

        return [.foregroundColor: UIColor.Team.textColor, .paragraphStyle: alignCenterStyle, .font: semiboldFont]
    }()

    static let buttonSubtitleAttribute: [NSAttributedString.Key: AnyObject] = {
        let alignCenterStyle = NSMutableParagraphStyle()
        alignCenterStyle.alignment = .center
        alignCenterStyle.paragraphSpacingBefore = 4
        alignCenterStyle.lineSpacing = 4

        let lightFont = FontSpec(.normal, .light).font!

        return [.foregroundColor: UIColor.Team.textColor, .paragraphStyle: alignCenterStyle, .font: lightFont]
    }()

    // MARK: - Adaptive Constraints

    private var loginHintAlignTop: NSLayoutConstraint!
    private var loginButtonAlignBottom: NSLayoutConstraint!
    
    // MARK: - UI Elements

    let contentStack: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.axis = .vertical

        return stackView
    }()

    let logoView: UIImageView = {
        let image = UIImage(named: "wire-logo-black")
        let imageView = UIImageView(image: image)
        imageView.accessibilityIdentifier = "WireLogo"
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.Team.textColor
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        return imageView
    }()
    
    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)

        return stackView
    }()

    let createAccountButton: LandingButton = {
        let button = LandingButton(title: createAccountButtonTitle, icon: .personalProfile, iconBackgroundColor: UIColor.Team.createTeamGreen)
        button.accessibilityIdentifier = "CreateAccountButton"
        button.addTapTarget(self, action: #selector(LandingViewController.createAccountButtonTapped(_:)))
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)

        return button
    }()

    let createTeamButton: LandingButton = {
        let button = LandingButton(title: createTeamButtonTitle, icon: .team, iconBackgroundColor: UIColor.Team.createAccountBlue)
        button.accessibilityIdentifier = "CreateTeamButton"
        button.addTapTarget(self, action: #selector(LandingViewController.createTeamButtonTapped(_:)))
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)

        return button
    }()

    let loginButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 4
        stackView.axis = .vertical
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)

        return stackView
    }()

    let loginHintsLabel: UILabel = {
        let label = UILabel()
        label.text = "landing.login.hints".localized
        label.font = LandingViewController.regularFont
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.Team.subtitleColor
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)

        return label
    }()

//    let loginButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("landing.login.button.title".localized, for: .normal)
//        button.accessibilityIdentifier = "LoginButton"
//        button.setTitleColor(UIColor.Team.textColor, for: .normal)
//        button.titleLabel?.font = LandingViewController.semiboldFont
//        button.setContentHuggingPriority(.required, for: .vertical)
//        button.setContentCompressionResistancePriority(.required, for: .vertical)
//
//        button.addTarget(self, action: #selector(LandingViewController.loginButtonTapped(_:)), for: .touchUpInside)
//
//        return button
//    }()
    
    let customBackendTitleLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "ConfigurationTitle"
        label.textAlignment = .center
        label.font = FontSpec(.normal, .bold).font!
        label.textColor = UIColor.Team.textColor
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    let customBackendSubtitleLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "ConfigurationLink"
        label.font = FontSpec(.small, .semibold).font!
        label.textColor = UIColor.Team.placeholderColor
        return label
    }()
    
    let customBackendSubtitleButton: UIButton = {
        let button = UIButton()
        button.setTitle("landing.custom_backend.more_info.button.title".localized.uppercased(), for: .normal)
        button.accessibilityIdentifier = "ShowMoreButton"
        button.setTitleColor(UIColor.Team.activeButton, for: .normal)
        button.titleLabel?.font = FontSpec(.small, .semibold).font!
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.addTarget(self, action: #selector(LandingViewController.showCustomBackendLink(_:)), for: .touchUpInside)
        return button
    }()
    
    let customBackendSubtitleStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        return stackView
    }()
    
    let customBackendStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stackView
    }()
    
    private var backImageView = UIImageView()
    private var logoCartoonImageView = UIImageView()
    private var logoCartoonShadowImageView = UIImageView()
    private var logoCartoonCharacterImageView = UIImageView()
    private var titleLabel = UILabel()
    private var loginButton = UIButton()
    private var registerButton = UIButton()

    private var forgotPasswordButton = ButtonWithLargerHitArea()
    //    (type: UIButtonTypeCustom)
    
    //    let cancelButton: IconButton = {
    //        let button = IconButton()
    //        button.setIcon(.cancel, with: .small, for: .normal)
    //        //        button.tintColor = .black
    //        button.translatesAutoresizingMaskIntoConstraints = false
    //        button.accessibilityIdentifier = "CancelButton"
    //        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    //        return button
    //    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.shared().tagOpenedLandingScreen(context: "email")
        view.backgroundColor = .dynamic(scheme: .background)

//        configureSubviews()
//        createConstraints()
        configureSubviewsForSecret()
        createConstraintsForSecret()
//        configureAccessibilityElements()

        updateForCurrentSizeClass(isRegular: traitCollection.horizontalSizeClass == .regular)
        updateBarButtonItem()
        disableTrackingIfNeeded()
        updateCustomBackendLabel()

        NotificationCenter.default.addObserver(
            forName: AccountManagerDidUpdateAccountsNotificationName,
            object: SessionManager.shared?.accountManager,
            queue: .main) { _ in
                self.updateBarButtonItem()
                self.disableTrackingIfNeeded()
        }
        
        NotificationCenter.default.addObserver(forName: BackendEnvironment.backendSwitchNotification, object: nil, queue: .main) { _ in
            self.updateCustomBackendLabel()
        }
        
        NotificationCenter.default.addObserver(forName: .guideStartUsingNotificationName, object: nil, queue: .main) { _ in
            self.logoAnimation()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .screenChanged, argument: logoView)
        self.logoAnimation()
    }

    

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let isRegular = traitCollection.horizontalSizeClass == .regular
        updateForCurrentSizeClass(isRegular: isRegular)
    }

    private func configureSubviews() {
        if #available(iOS 11, *) {
            additionalSafeAreaInsets.top = -44
        }

        customBackendSubtitleStack.addArrangedSubview(customBackendSubtitleLabel)
        customBackendSubtitleStack.addArrangedSubview(customBackendSubtitleButton)

        customBackendStack.addArrangedSubview(customBackendTitleLabel)
        customBackendStack.addArrangedSubview(customBackendSubtitleStack)

        contentStack.addArrangedSubview(logoView)
        contentStack.addArrangedSubview(customBackendStack)

        buttonStackView.addArrangedSubview(createAccountButton)
        buttonStackView.addArrangedSubview(createTeamButton)
        contentStack.addArrangedSubview(buttonStackView)

        loginButtonsStackView.addArrangedSubview(loginHintsLabel)
        loginButtonsStackView.addArrangedSubview(loginButton)
        contentStack.addArrangedSubview(loginButtonsStackView)
        
        // Hide team creation for now
        createTeamButton.isHidden = true

        view.addSubview(contentStack)
    }

    private func createConstraints() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // contentStack
            contentStack.topAnchor.constraint(greaterThanOrEqualTo: safeTopAnchor, constant: 12),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: safeBottomAnchor, constant: -12),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            contentStack.centerYAnchor.constraint(equalTo: safeCenterYAnchor),

            // buttons width
            createAccountButton.widthAnchor.constraint(lessThanOrEqualToConstant: 256),
            createTeamButton.widthAnchor.constraint(lessThanOrEqualToConstant: 256),
            loginButtonsStackView.widthAnchor.constraint(lessThanOrEqualToConstant: 256),

            // logoView
            logoView.heightAnchor.constraint(lessThanOrEqualToConstant: 31)
            ])
    }
    
    private func configureSubviewsForSecret() {
        if #available(iOS 11, *) {
            additionalSafeAreaInsets.top = -44
        }
        [titleLabel, logoCartoonImageView, logoCartoonShadowImageView, logoCartoonCharacterImageView, loginButton, registerButton, forgotPasswordButton].forEach(view.addSubview)
        logoCartoonImageView.image = UIImage.init(named: "logo_cartoon")
        logoCartoonShadowImageView.image = UIImage.init(named: "logo_cartoon_shadow")
        logoCartoonCharacterImageView.image = UIImage.init(named: "logo_cartoon_character")
        logoCartoonShadowImageView.alpha = 0
        
        titleLabel.textColor = .dynamic(scheme: .subtitle)
        titleLabel.font = UIFont(15, .regular)
        titleLabel.text = "login.intro.text.new".localized
        
        loginButton.setTitle("registration.signin.title".localized, for: .normal)
        loginButton.layer.cornerRadius = 24
        loginButton.backgroundColor = .dynamic(scheme: .brand)
        loginButton.addTarget(self, action: #selector(LandingViewController.loginButtonTapped), for: .touchUpInside)
        
        registerButton.setTitle("registration.title".localized, for: .normal)
        registerButton.setTitleColor(.dynamic(scheme: .title), for: .normal)
        registerButton.layer.cornerRadius = 24
        registerButton.layer.borderWidth = 1
        registerButton.layer.borderColor = UIColor.dynamic(scheme: .separator).cgColor
        registerButton.addTarget(self, action: #selector(LandingViewController.createAccountButtonTapped(_:)), for: .touchUpInside)
        
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.setTitleColor(.dynamic(scheme: .subtitle), for: .normal)
        forgotPasswordButton.setTitle("signin.forgot_password".localized.uppercased(), for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont(11, .regular)
        forgotPasswordButton.addTarget(self, action: #selector(LandingViewController.resetPassword), for: .touchUpInside)
        
    }
    
    private func createConstraintsForSecret() {
        
        constrain(view, logoCartoonImageView, logoCartoonShadowImageView, logoCartoonCharacterImageView, titleLabel, loginButton, registerButton) { (view, logoCartoonImage, logoCartoonShadowImage, logoCartoonCharacterImage, titleLabel, loginButton, registerButton) in
            //            backImageView.edges == view.edges
            
            logoCartoonImage.top == view.top + 230
            logoCartoonImage.centerX == view.centerX
            logoCartoonImage.width == 56
            logoCartoonImage.height == 56
            
            logoCartoonShadowImage.top == view.top + 294
            logoCartoonShadowImage.centerX == view.centerX
            logoCartoonShadowImage.width == 40
            logoCartoonShadowImage.height == 4
            
            logoCartoonCharacterImage.top == logoCartoonShadowImage.bottom + 20
            logoCartoonCharacterImage.centerX == view.centerX
            logoCartoonCharacterImage.width == 102
            logoCartoonCharacterImage.height == 22
            
            titleLabel.top == logoCartoonCharacterImage.bottom + 16
            titleLabel.centerX == view.centerX
            
            registerButton.bottom == view.bottom - 104 - UIScreen.safeArea.bottom
            registerButton.left == view.left + 32
            registerButton.right == view.right - 32
            registerButton.height == 48
            
           
            loginButton.left == view.left + 32
            loginButton.right == view.right - 32
            loginButton.height == 48
            loginButton.bottom == registerButton.top - 20
        }
        
        constrain(registerButton, forgotPasswordButton) { (registerButton, forgotPasswordButton) in

            forgotPasswordButton.top == registerButton.bottom + 24
            forgotPasswordButton.centerX == registerButton.centerX
        }

    }


    // MARK: - Adaptivity Events
    
    private func updateLogoView() {
        logoView.isHidden = isCustomBackend
    }
    
    var isCustomBackend: Bool {
        switch BackendEnvironment.shared.environmentType.value {
        case .production, .staging:
            return false
        case .custom:
            return true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isIPadRegular() || isCustomBackend {
            contentStack.spacing = 32
        } else if view.frame.height <= 640 {
            contentStack.spacing = view.frame.height / 5
        } else {
            contentStack.spacing = view.frame.height / 4.1
        }

        updateLogoView()
    }

    func updateForCurrentSizeClass(isRegular: Bool) {
        updateStackViewAxis(isRegular: isRegular)
    }

    private func updateStackViewAxis(isRegular: Bool) {
        switch traitCollection.horizontalSizeClass {
        case .regular:
            buttonStackView.axis = .horizontal
            buttonStackView.alignment = .top

        default:
            buttonStackView.axis = .vertical
            buttonStackView.alignment = .center
        }
    }

    private func updateBarButtonItem() {
        if SessionManager.shared?.firstAuthenticatedAccount == nil {
            navigationItem.rightBarButtonItem = nil
        } else {
            let cancelItem = UIBarButtonItem(icon: .cross, target: self, action: #selector(cancelButtonTapped))
            cancelItem.accessibilityIdentifier = "CancelButton"
            cancelItem.accessibilityLabel = "general.cancel".localized
            navigationItem.rightBarButtonItem = cancelItem
        }
    }
    
    private func updateCustomBackendLabel() {
        switch BackendEnvironment.shared.environmentType.value {
        case .production, .staging:
            customBackendStack.isHidden = true
            buttonStackView.alpha = 1
        case .custom(url: let url):
            customBackendTitleLabel.text = "landing.custom_backend.title".localized(args: BackendEnvironment.shared.title)
            customBackendSubtitleLabel.text = url.absoluteString.uppercased()
            customBackendStack.isHidden = false
            buttonStackView.alpha = 0
            createTeamButton.isHidden = false
        }
        updateLogoView()
    }
    
    private func disableTrackingIfNeeded() {
        if SessionManager.shared?.firstAuthenticatedAccount == nil {
            TrackingManager.shared.disableCrashAndAnalyticsSharing = true
        }
    }

    // MARK: - Accessibility

    private func configureAccessibilityElements() {
        logoView.isAccessibilityElement = true
        logoView.accessibilityLabel = "landing.header".localized
        logoView.accessibilityTraits.insert(.header)
    }

    private static let createAccountButtonTitle: NSAttributedString = {
        let title = "landing.create_account.title".localized && LandingViewController.buttonTitleAttribute
        let subtitle = ("\n" + "landing.create_account.subtitle".localized) && LandingViewController.buttonSubtitleAttribute

        return title + subtitle
    }()

    private static let createTeamButtonTitle: NSAttributedString = {
        let title = "landing.create_team.title".localized && LandingViewController.buttonTitleAttribute
        let subtitle = ("\n" + "landing.create_team.subtitle".localized) && LandingViewController.buttonSubtitleAttribute

        return title + subtitle
    }()

    override func accessibilityPerformEscape() -> Bool {
        guard SessionManager.shared?.firstAuthenticatedAccount != nil else {
            return false
        }

        cancelButtonTapped()
        return true
    }

    // MARK: - Button tapped target
    
    @objc public func showCustomBackendLink(_ sender: AnyObject!) {
        let backendTitle = BackendEnvironment.shared.title
        let jsonURL = customBackendSubtitleLabel.text?.lowercased() ?? ""
        let alert = UIAlertController(title: "landing.custom_backend.more_info.alert.title".localized(args: backendTitle), message: "\(jsonURL)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "general.ok".localized, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @objc public func createAccountButtonTapped(_ sender: AnyObject!) {
        Analytics.shared().tagOpenedUserRegistration(context: "email")
        delegate?.landingViewControllerDidChooseCreateAccount()
    }

    @objc public func createTeamButtonTapped(_ sender: AnyObject!) {
        Analytics.shared().tagOpenedTeamCreation(context: "email")
        delegate?.landingViewControllerDidChooseCreateTeam()
    }

    @objc public func loginButtonTapped(_ sender: AnyObject!) {
        Analytics.shared().tagOpenedLogin(context: "email")
        delegate?.landingViewControllerDidChooseLogin()
    }
    
    @objc public func cancelButtonTapped() {
        guard let account = SessionManager.shared?.firstAuthenticatedAccount else { return }
        SessionManager.shared!.select(account)
    }
    
    @objc private func resetPassword() {
        URL.wr_passwordReset.openInApp(above: self)
    }
    
    private func logoAnimation() {
        self.logoCartoonImageView.frame.origin.y -= 30
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            self.logoCartoonImageView.frame.origin.y += 30
            self.logoCartoonShadowImageView.alpha = 1
        }) { (_) in
            
        }
    }

    // MARK: - AuthenticationCoordinatedViewController
    
    func executeErrorFeedbackAction(_ feedbackAction: AuthenticationErrorFeedbackAction) {
        //no-op
    }
    
    func displayError(_ error: Error) {
        //no-op
    }
}
