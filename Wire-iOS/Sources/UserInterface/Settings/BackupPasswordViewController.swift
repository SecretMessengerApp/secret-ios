
import UIKit
import WireUtilities

struct Password {
    static let minimumCharacters = 8
    let value: String
    
    init?(_ value: String) {
        guard value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count >= Password.minimumCharacters else { return nil }
        self.value = value
    }
}

extension BackupViewController {
    func requestBackupPassword(completion: @escaping (Password?) -> Void) {
        let passwordController = BackupPasswordViewController { controller, password in
            controller.dismiss(animated: true) {
                completion(password)
            }
        }
        let navigationController = KeyboardAvoidingViewController(viewController: passwordController).wrapInNavigationController()
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }
}

final class BackupPasswordViewController: UIViewController {
    
    typealias Completion = (BackupPasswordViewController, Password?) -> Void
    var completion: Completion?

    fileprivate var password: Password?
    private let passwordView = SimpleTextField()
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    

    private let subtitleLabel = UILabel(
        key: "self.settings.history_backup.password.description",
        size: .medium,
        weight: .regular,
        color: .textForeground,
        variant: .light
    )
    
    init(completion: @escaping Completion) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        setupViews()
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordView.becomeFirstResponder()
    }

    private func setupViews() {
        view.backgroundColor = UIColor.dynamic(scheme: .groupBackground)
        
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = UIColor.dynamic(scheme: .subtitle)
        [passwordView, subtitleLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        passwordView.colorSchemeVariant = .light
        passwordView.placeholder = "self.settings.history_backup.password.placeholder".localized.localizedUppercase
        passwordView.accessibilityIdentifier = "password input"
        passwordView.returnKeyType = .done
        passwordView.isSecureTextEntry = true
        passwordView.delegate = self
    }
    
    private func createConstraints() {
        NSLayoutConstraint.activate([
            passwordView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            passwordView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            passwordView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            passwordView.heightAnchor.constraint(equalToConstant: 56),
            subtitleLabel.topAnchor.constraint(equalTo: passwordView.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupNavigationBar() {
//        navigationController?.navigationBar.backgroundColor = UIColor.from(scheme: .barBackground, variant: .light)
//        navigationController?.navigationBar.setBackgroundImage(.singlePixelImage(with: UIColor.from(scheme: .barBackground, variant: .light)), for: .default)
//        navigationController?.navigationBar.tintColor = UIColor.dynamic(scheme: .barTint)
//        navigationController?.navigationBar.barTintColor = UIColor.dynamic(scheme: .title)
//        navigationController?.navigationBar.titleTextAttributes = DefaultNavigationBar.titleTextAttributes(for: .light)
        
        title = "self.settings.history_backup.password.title".localized(uppercased: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "self.settings.history_backup.password.cancel".localized(uppercased: true),
            style: .plain,
            target: self,
            action: #selector(cancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "self.settings.history_backup.password.next".localized(uppercased: true),
            style: .done,
            target: self,
            action: #selector(completeWithCurrentResult)
        )
        navigationItem.rightBarButtonItem?.tintColor = .accent()
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    fileprivate func updateState(with text: String) {
        password = Password(text)
        navigationItem.rightBarButtonItem?.isEnabled = nil != password
    }
    
    @objc dynamic fileprivate func cancel() {
        completion?(self, nil)
    }
    
    @objc dynamic fileprivate func completeWithCurrentResult() {
        completion?(self, password)
    }
}

extension BackupPasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
     
        if let _ = string.rangeOfCharacter(from: CharacterSet.newlines) {
            if let _ = password {
                completeWithCurrentResult()
            }
            return false
        }
        
        let newString = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        self.updateState(with: newString)
        
        return true
    }
}
