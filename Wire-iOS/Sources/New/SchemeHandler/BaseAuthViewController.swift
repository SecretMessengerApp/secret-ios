

import UIKit

class BaseAuthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .dynamic(scheme: .background)
        addViewAndConstraints()
        
        dismissBtn.addTarget(self, action: #selector(dismissBtnDidTap), for: .touchUpInside)
        authBtn.addTarget(self, action: #selector(authBtnDidTap), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(cancelBtnDidTap), for: .touchUpInside)
        
        fetchInfo()
    }
    
    func fetchInfo() {}
    
    private func addViewAndConstraints() {
        [dismissBtn, iconView, nameLabel, authBtn, cancelBtn].forEach { v in
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
        }
        
        NSLayoutConstraint.activate(
            [
                dismissBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                dismissBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
                
                nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -32),
                nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                iconView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -24),
                
                cancelBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -UIScreen.safeArea.bottom - 64),
                cancelBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                authBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                authBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                authBtn.bottomAnchor.constraint(equalTo: cancelBtn.topAnchor, constant: -24),
                authBtn.heightAnchor.constraint(equalToConstant: 44)
            ]
        )
    }
    
    private lazy var dismissBtn: IconButton = {
        let btn = IconButton()
        btn.setIcon(.cross, size: .tiny, for: .normal)
        btn.setIconColor(scheme: .iconNormal, for: .normal)
        return btn
    }()
    
    private lazy var iconView = UIImageView()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .dynamic(scheme: .note)
        return label
    }()
    
    private lazy var authBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("app.scheme.login.authorization".localized, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        btn.backgroundColor = .dynamic(scheme: .brand)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()
    
    private lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("general.cancel".localized, for: .normal)
        btn.setTitleColor(.dynamic(scheme: .note), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        return btn
    }()
}


extension BaseAuthViewController {

    @objc func dismissBtnDidTap() {
        dismiss(animated: true)
    }
    
    @objc func authBtnDidTap() {}
    
    @objc func cancelBtnDidTap() {
        dismissBtnDidTap()
    }
    
    func config(iconURLString: String?, name: String?) {
        iconView.image(at: iconURLString)
        nameLabel.text = name
    }
    
    func config(iconImage: UIImage?, name: String?) {
        iconView.image = iconImage
        nameLabel.text = name
    }
}
