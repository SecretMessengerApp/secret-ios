//
// Wire
// Copyright (C) 2017 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation
import UIKit
import Cartography

@objc protocol LandingViewControllerDelegate {
    func landingViewControllerDidChooseCreateAccount()
    func landingViewControllerDidChooseCreateTeam()
    func landingViewControllerDidChooseLogin()
}

/// Landing screen for choosing create team or personal account
final class LandingViewController: AuthenticationStepViewController {
    weak var authenticationCoordinator: AuthenticationCoordinator?

    var delegate: LandingViewControllerDelegate? {
        return authenticationCoordinator
    }

    fileprivate var device: DeviceProtocol

    // MARK: - UI styles

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

        let lightFont = FontSpec(.normal, .light).font!

        return [.foregroundColor: UIColor.Team.textColor, .paragraphStyle: alignCenterStyle, .font: lightFont]
    }()

    // MARK: - constraints for iPad

    private var logoAlignTop: NSLayoutConstraint!
    private var loginButtonAlignBottom: NSLayoutConstraint!
    private var loginHintAlignTop: NSLayoutConstraint!
    private var headlineAlignBottom: NSLayoutConstraint!

    // MARK: - subviews

    let logoView: UIImageView = {
        let image = UIImage(named: "wire-logo-black")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .center
        imageView.tintColor = UIColor.Team.textColor
        return imageView
    }()
    
    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 24
        stackView.axis = .vertical

        return stackView
    }()

    let createAccountButton: LandingButton = {
        let button = LandingButton(title: createAccountButtonTitle, icon: .selfProfile, iconBackgroundColor: UIColor.Team.createTeamGreen)
        button.accessibilityIdentifier = "CreateAccountButton"
        button.addTarget(self, action: #selector(LandingViewController.createAccountButtonTapped(_:)), for: .touchUpInside)

        return button
    }()

    let createTeamButton: LandingButton = {
        let button = LandingButton(title: createTeamButtonTitle, icon: .team, iconBackgroundColor: UIColor.Team.createAccountBlue)
        button.accessibilityIdentifier = "CreateTeamButton"
        button.addTarget(self, action: #selector(LandingViewController.createTeamButtonTapped(_:)), for: .touchUpInside)

        return button
    }()

    let headerContainerView = UIView()

    let loginHintsLabel: UILabel = {
        let label = UILabel()
        label.text = "landing.login.hints".localized
        label.font = LandingViewController.regularFont
        label.textColor = UIColor.Team.subtitleColor

        return label
    }()

//    let loginButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("landing.login.button.title".localized, for: .normal)
//        button.accessibilityIdentifier = "LoginButton"
//        button.setTitleColor(UIColor.Team.textColor, for: .normal)
//        button.titleLabel?.font = LandingViewController.semiboldFont
//
//        button.addTarget(self, action: #selector(LandingViewController.loginButtonTapped(_:)), for: .touchUpInside)
//
//        return button
//    }()

    let navigationBar: UINavigationBar = {
        let bar = UINavigationBar()
        bar.shadowImage = UIImage()
        bar.setBackgroundImage(UIImage(), for: .default)
        return bar
    }()
    private var backImageView = UIImageView()
    private var logoImageView = UIImageView()
    private var titleLabel = UILabel()
    private var loginButton = UIButton()
    private var registerButton = UIButton()
    // 新增忘记密码按钮
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
    /// init method for injecting mock device
    ///
    /// - Parameter device: Provide this param for testing only
    init(device: DeviceProtocol = UIDevice.current) {
        self.device = device

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Analytics.shared().tagOpenedLandingScreen(context: "email")

//        [headerContainerView, buttonStackView, loginHintsLabel, loginButton].forEach(view.addSubview)
//        headerContainerView.addSubview(logoView)
        
//        [createAccountButton, createTeamButton].forEach { button in
//            buttonStackView.addArrangedSubview(button)
//        }
        
        [titleLabel, logoImageView, loginButton, registerButton, forgotPasswordButton].forEach(view.addSubview)
        logoImageView.image = UIImage.init(named: "logo-landing")
        
        titleLabel.textColor = UIColor.black666
        titleLabel.font = UIFont(17, .regular)
        titleLabel.text = "login.intro.text".localized
        
        loginButton.setTitle("registration.signin.title".localized, for: .normal)
        loginButton.layer.cornerRadius = 24
        loginButton.backgroundColor = UIColor.init(rgb: 0x0b63ff)
        loginButton.addTarget(self, action: #selector(LandingViewController.loginButtonTapped), for: .touchUpInside)
        
        registerButton.setTitle("registration.title".localized, for: .normal)
        registerButton.setTitleColor(UIColor.black333, for: .normal)
        registerButton.layer.cornerRadius = 24
        registerButton.layer.borderWidth = 1
        registerButton.layer.borderColor = UIColor.black999.cgColor
        registerButton.addTarget(self, action: #selector(LandingViewController.createAccountButtonTapped(_:)), for: .touchUpInside)
        
        //        forgotPasswordButton.isHidden = true
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.setTitleColor(UIColor.black999, for: .normal)
        forgotPasswordButton.setTitleColor(UIColor.init(white: 1, alpha: 0.4), for: .highlighted)
        forgotPasswordButton.setTitle("signin.forgot_password".localized.uppercased(), for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont(11, .regular)
        forgotPasswordButton.addTarget(self, action: #selector(LandingViewController.resetPassword), for: .touchUpInside)
        
        
//        cancelButton.isHidden = SessionManager.shared?.firstAuthenticatedAccount == nil

        self.view.backgroundColor = UIColor.Team.background
        navigationBar.pushItem(navigationItem, animated: false)
        navigationBar.tintColor = .black
        view.addSubview(navigationBar)
        
        

        self.createConstraints()
//        self.configureAccessibilityElements()

//        updateStackViewAxis()
//        updateConstraintsForIPad()
        updateBarButtonItem()
        disableTrackingIfNeeded()

        NotificationCenter.default.addObserver(
            forName: AccountManagerDidUpdateAccountsNotificationName,
            object: SessionManager.shared?.accountManager,
            queue: nil) { _ in
                self.updateBarButtonItem()
                self.disableTrackingIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(animated)
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

//        updateStackViewAxis()
//        updateConstraintsForIPad()

    }

    private func createConstraints() {

        let safeArea = view.safeAreaLayoutGuideOrFallback
        navigationBar.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true

        constrain(view, navigationBar) { selfView, navigationBar in
            navigationBar.left == selfView.left
            navigationBar.right == selfView.right
        }
        
        constrain(view, logoImageView, titleLabel, loginButton, registerButton) { (view, logoImage, titleLabel, loginButton, registerButton) in
            //            backImageView.edges == view.edges
            
            logoImage.top == view.top + 130
            logoImage.centerX == view.centerX
            logoImage.width == 235
            logoImage.height == 108
            
            titleLabel.top == logoImage.bottom + 32
            titleLabel.centerX == view.centerX
            
            loginButton.top == titleLabel.bottom + 32
            loginButton.left == view.left + 32
            loginButton.right == view.right - 32
            loginButton.height == 48
            
            registerButton.top == loginButton.bottom + 16
            registerButton.left == view.left + 32
            registerButton.right == view.right - 32
            registerButton.height == 48
            
        }
        
        constrain(registerButton, forgotPasswordButton) { (registerButton, forgotPasswordButton) in
            
            forgotPasswordButton.top == registerButton.bottom + 13
            forgotPasswordButton.centerX == registerButton.centerX
        }

//        constrain(logoView, headerContainerView) { logoView, headerContainerView in
//
//            logoAlignTop = logoView.top == headerContainerView.top + 72 ~ 500.0
//            logoView.centerX == headerContainerView.centerX
//            logoView.width == 96
//            logoView.height == 31
//
//            logoView.bottom <= headerContainerView.bottom - 16
//
//            if UIDevice.current.userInterfaceIdiom == .pad {
//                headlineAlignBottom = logoView.bottom == headerContainerView.bottom - 80
//            }
//        }
//
//        constrain(self.view, headerContainerView, buttonStackView) { selfView, headerContainerView, buttonStackView in
//
//            headerContainerView.width == selfView.width
//            headerContainerView.centerX == selfView.centerX
//
//            buttonStackView.centerX == selfView.centerX
//            buttonStackView.centerY == selfView.centerY
//
//            headerContainerView.bottom == buttonStackView.top
//        }
//
//        headerContainerView.topAnchor.constraint(equalTo: safeTopAnchor).isActive = true
//
//        constrain(self.view, buttonStackView, loginHintsLabel, loginButton) {
//            selfView, buttonStackView, loginHintsLabel, loginButton in
//            buttonStackView.bottom <= loginHintsLabel.top - 16
//
//            loginHintsLabel.bottom == loginButton.top - 16
//            loginHintsLabel.centerX == selfView.centerX
//            if UIDevice.current.userInterfaceIdiom == .pad {
//                loginHintAlignTop = loginHintsLabel.top == buttonStackView.bottom + 80
//            }
//
//            loginButton.centerX == selfView.centerX
//            loginButton.height >= 44
//            loginButton.width >= 44
//            loginButtonAlignBottom = loginButton.bottom == selfView.bottomMargin - 32 ~ 500.0
//        }
//
//        [createAccountButton, createTeamButton].forEach() { button in
//            button.setContentCompressionResistancePriority(.required, for: .vertical)
//            button.setContentCompressionResistancePriority(.required, for: .horizontal)
//        }
    }

    fileprivate func updateConstraintsForIPad() {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }

        switch self.traitCollection.horizontalSizeClass {
        case .compact:
            loginHintAlignTop.isActive = false
            headlineAlignBottom.isActive = false
            logoAlignTop.isActive = true
            loginButtonAlignBottom.isActive = true
        default:
            logoAlignTop.isActive = false
            loginButtonAlignBottom.isActive = false
            loginHintAlignTop.isActive = true
            headlineAlignBottom.isActive = true
        }
    }

    func updateStackViewAxis() {
        let userInterfaceIdiom = device.userInterfaceIdiom
        guard userInterfaceIdiom == .pad else { return }

        switch self.traitCollection.horizontalSizeClass {
        case .regular:
            buttonStackView.axis = .horizontal
        default:
            buttonStackView.axis = .vertical
        }
    }

    private func updateBarButtonItem() {
        if SessionManager.shared?.firstAuthenticatedAccount == nil {
            navigationBar.topItem?.rightBarButtonItem = nil
        } else {
            let cancelItem = UIBarButtonItem(icon: .cancel, target: self, action: #selector(cancelButtonTapped))
            cancelItem.accessibilityIdentifier = "CancelButton"
            cancelItem.accessibilityLabel = "general.cancel".localized
            navigationBar.topItem?.rightBarButtonItem = cancelItem
        }
    }
    
    private func disableTrackingIfNeeded() {
        if SessionManager.shared?.firstAuthenticatedAccount == nil {
            TrackingManager.shared.disableCrashAndAnalyticsSharing = true
        }
    }

    // MARK: - Accessibility

    private func configureAccessibilityElements() {
        logoView.isAccessibilityElement = false

        headerContainerView.isAccessibilityElement = true
        headerContainerView.accessibilityLabel = "landing.app_name".localized + " " + "landing.title".localized
        headerContainerView.accessibilityTraits = .header
        headerContainerView.shouldGroupAccessibilityChildren = true
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
        UIApplication.shared.open(URL.wr_passwordReset)
        
//        Analytics.shared().tagResetPassword(true, from: ResetFromSignIn)
    }

    override var prefersStatusBarHidden: Bool {
        // FIXME: We have to hide the status bar when running tests as we are not using a test host.
        // Some view controllers we test using snapshots requets a status bar appearance update when
        // they appear. If that happens we will query the topmost view controller which will be the
        // LandingViewController in tests as we are using no test host application to run tests.
        // Unfortunately this hack is needed until we either change how we manage the status bar or
        // start using a test host to run tests.
        return ProcessInfo.processInfo.isRunningTests
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
}
