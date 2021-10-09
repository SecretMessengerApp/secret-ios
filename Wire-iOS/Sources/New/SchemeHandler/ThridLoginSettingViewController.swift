//
//  ThridLoginPasswordSettingViewController.swift
//  Wire-iOS
//

import UIKit
import OnePasswordExtension

class ThridLoginSettingViewController: UIViewController, UITextFieldDelegate {
    
    public var password: String?
    public var againPassword: String?
    
    public var pageTitle: String? {
        didSet {
            guard let title = pageTitle else {return}
            self.titleLabel.text = title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .dynamic(scheme: .background)

        [backIcon, titleLabel, emailLabel, passwordTextField, passwordAgainTextField].forEach(view.addSubview)
        createConstraints()
    }
    
    func createConstraints() {
        let constraints = [
            backIcon.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 48),
            backIcon.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 32),
            titleLabel.topAnchor.constraint(equalTo: backIcon.topAnchor, constant: 150),
            emailLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 32),
            emailLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 100),
            passwordTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 32),
            passwordTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 32),
            passwordTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -32),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            passwordAgainTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 32),
            passwordAgainTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 32),
            passwordAgainTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -32),
            passwordAgainTextField.heightAnchor.constraint(equalToConstant: 40)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    fileprivate lazy var backIcon: IconButton = {
        let icon = IconButton(style: .navigation, variant: .light)
        icon.setIcon(.backArrow, size: .tiny, for: .normal)
        icon.setIconColor(scheme: .title, for: .normal)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.addTarget(self, action: #selector(ThridLoginSettingViewController.cancel), for: .touchUpInside)
        return icon
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22)
        label.textColor = .dynamic(scheme: .title)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .dynamic(scheme: .title)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate lazy var passwordTextField: RegistrationTextField = {
        let textfield = RegistrationTextField()
        textfield.placeholder = "password"
        textfield.isSecureTextEntry = true
        textfield.returnKeyType = UIReturnKeyType.done
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.accessibilityIdentifier = "passwordTextField"
        textfield.delegate = self
        return textfield
    }()
    
    fileprivate lazy var passwordAgainTextField: RegistrationTextField = {
        let textfield = RegistrationTextField()
        textfield.placeholder = "Confirm password again"
        textfield.isSecureTextEntry = true
        textfield.returnKeyType = UIReturnKeyType.done
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.accessibilityIdentifier = "passwordAgainTextField"
        textfield.delegate = self
        return textfield
    }()
    
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        password = passwordTextField.text
        againPassword = passwordAgainTextField.text
        if textField.accessibilityIdentifier == "passwordTextField" {
            passwordConfirm()
        }
        if textField.accessibilityIdentifier == "passwordAgainTextField" {
            passwordAgainConfim()
        }
        return true
    }
    
    func passwordConfirm() {
        fatal("Your subclasses must implement `passwordConfirm`.")
    }
    
    func passwordAgainConfim() {
        fatal("Your subclasses must implement `passwordAgainConfim`.")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Special case: After a sign in try and text change we need to reset both accessory views
        if textField == self.passwordTextField {
            self.checkPasswordFieldAccessoryView()
        }
    }

    
    func checkPasswordFieldAccessoryView() {
        if self.passwordTextField.text?.count > 0 {
            self.passwordTextField.rightAccessoryView = .confirmButton
        } else if OnePasswordExtension.shared().isAppExtensionAvailable() {
            self.passwordTextField.rightAccessoryView = .custom
        } else {
            self.passwordTextField.rightAccessoryView = .none
        }
    }
}

class ThridLoginPasswordSettingViewController: ThridLoginSettingViewController {
    
    let oldPassword: String
    let token: String
    let userid: String
    let userinfo: UserInfo
    let email: String
    let fromid: String
    let label: String
    let coordinator: AuthenticationCoordinator
    
    init(coordinator: AuthenticationCoordinator, email: String, fromid: String, userid: String, label: String, oldPassword: String, userinfo: UserInfo, token: String) {
        self.oldPassword = oldPassword
        self.userinfo = userinfo
        self.token = token
        self.email = email
        self.userid = userid
        self.coordinator = coordinator
        self.fromid = fromid
        self.label = label
        super.init(nibName: nil, bundle: nil)
        self.pageTitle = "Set password"
        self.emailLabel.text = email
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func passwordAgainConfim() {
        guard let password = self.password, let againpassword = self.againPassword, !password.isEmpty, !againpassword.isEmpty, password == againpassword else {
            HUD.error("The password cannot be empty or the two passwords are inconsistent")
            return
        }
        AuthLoginService.updatePassword(oldPassword: self.oldPassword, newPassword: password, token: self.token) { (result) in
            switch result {
            case .success:
                
                AuthLoginService.appThirdLoginAuth(fromid: self.fromid, email: self.email, userid: self.userid, label: self.label, password: password) { (result) in
                    switch result {
                    case .loginSuccess(let json, let headers, _, _):
                        guard let cookie = headers?["Set-Cookie"] as? String else {return}
                        let cookieData = HTTPCookie.extractCookieData(from: cookie, url: URL(string: "isecret.im")!)
                        guard let cookiedata = cookieData else {return}
                        let userIdentifier = json["user"].stringValue
                        guard let useruuid = UUID(uuidString: userIdentifier) else {return}
                        let uinfo = UserInfo(identifier: useruuid, cookieData: cookiedata)
                        
                        let credential = ZMEmailCredentials.init(email: self.email, password: password)
                        self.coordinator.stateController.transition(to: .authenticateEmailCredentials(credential))
                        SessionManager.shared?.unauthenticatedSession?.authenticationStatus.loginSucceeded(with: uinfo)
                        self.dismiss(animated: true, completion: nil)
                    case .loginFailure(let error):
                        HUD.error(error)
                    }
                }
                self.dismiss(animated: true, completion: nil)
            case .failure(let error):
                HUD.error(error)
            }
        }
    }
    
}

class ThridLoginBindSettingViewController: ThridLoginSettingViewController {
    
    let fromid: String
    let email: String
    let label: String
    let userid: String
    let coordinator: AuthenticationCoordinator
    
    init(coordinator: AuthenticationCoordinator, fromid: String, email: String, userid: String, label: String) {
        self.fromid = fromid
        self.email = email
        self.label = label
        self.userid = userid
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        self.pageTitle = "Bind account"
        self.emailLabel.text = email
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordAgainTextField.isHidden = true
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.confirmButton.addTarget(self, action: #selector(passwordConfirm), for: .touchUpInside)
    }
    
    @objc override func passwordConfirm() {
        password = passwordTextField.text
        guard let passw = self.password, !passw.isEmpty else {
            HUD.error("Please input a password")
            return
        }
        AuthLoginService.appThirdLoginAuth(fromid: self.fromid, email: self.email, userid: self.userid, label: self.label, password: passw) { (result) in
            switch result {
            case .loginSuccess(let json, let headers, _, _):
                
                if let code = json["code"].int {
                    var codeDescrible = ""
                    if code == 1004 {
                        codeDescrible = "Password input error"
                    } else if code == 400 {
                        codeDescrible = "Minimum 6 digits of password"
                    }
                    HUD.error("Binding failed:\(codeDescrible)")
                    return
                }
                guard let cookie = headers?["Set-Cookie"] as? String else {return}
                let cookieData = HTTPCookie.extractCookieData(from: cookie, url: URL(string: "isecret.im")!)
                guard let cookiedata = cookieData else {return}
                let userIdentifier = json["user"].stringValue
                guard let useruuid = UUID(uuidString: userIdentifier) else {return}
                let uinfo = UserInfo(identifier: useruuid, cookieData: cookiedata)
                
                let credential = ZMEmailCredentials.init(email: self.email, password: passw)
                self.coordinator.stateController.transition(to: .authenticateEmailCredentials(credential))
                SessionManager.shared?.unauthenticatedSession?.authenticationStatus.loginSucceeded(with: uinfo)
                self.dismiss(animated: true, completion: nil)
            case .loginFailure(let error):
                HUD.error(error)
            }
        }
    }
    
}
