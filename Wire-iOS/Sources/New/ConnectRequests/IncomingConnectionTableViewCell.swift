

import UIKit

final class IncomingConnectionTableViewCell: UITableViewCell {
    
    private let userImageView = UserImageView()
    private let usernameLabel = UILabel()
    private let userHandleLabel = UILabel()
    private let acceptButton = Button(style: .full)
    private let ignoreButton = Button(style: .empty)
    
    var acceptBlock: (() -> Void)?
    var ignoreBlock: (() -> Void)?
    
    var user: ZMUser! {
        didSet {
            userImageView.user = user
            let viewModel = UserNameDetailViewModel(
                user: user,
                fallbackName: "",
                addressBookName: user.zmUser?.addressBookEntry?.cachedName
            )
            
            usernameLabel.attributedText = viewModel.title
            usernameLabel.accessibilityIdentifier = "name"
            userHandleLabel.attributedText = viewModel.firstSubtitle
            userHandleLabel.accessibilityIdentifier = "handle"
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .dynamic(scheme: .cellBackground)
        selectionStyle = .none
        configureSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSubviews() {
        userImageView.userSession = ZMUserSession.shared()
        userImageView.initialsFont = UIFont.systemFont(ofSize: 20, weight: .semibold).monospaced()

        acceptButton.accessibilityLabel = "accept"
        acceptButton.setTitle("inbox.connection_request.connect_button_title".localized(uppercased: true), for: .normal)
        acceptButton.addTarget(self, action: #selector(onAcceptButton), for: .touchUpInside)

        ignoreButton.accessibilityLabel = "ignore"
        ignoreButton.setTitle("inbox.connection_request.ignore_button_title".localized(uppercased: true), for: .normal)
        ignoreButton.addTarget(self, action: #selector(onIgnoreButton), for: .touchUpInside)

        userImageView.accessibilityLabel = "user image"
        userImageView.shouldDesaturate = false
        userImageView.size = .big
//        userImageView.user = self.user
//        self.setupLabelText()
        [userImageView, usernameLabel, userHandleLabel, acceptButton, ignoreButton].forEach(contentView.addSubview)

        createSeparatorConstraints()
    }
    
    func createSeparatorConstraints() {
        [userImageView, usernameLabel, userHandleLabel, acceptButton, ignoreButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            userImageView.widthAnchor.constraint(equalToConstant: 38),
            userImageView.heightAnchor.constraint(equalToConstant: 38),
            userImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            userImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            usernameLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 16),
            usernameLabel.topAnchor.constraint(equalTo: userImageView.topAnchor),
            
            userHandleLabel.leftAnchor.constraint(equalTo: usernameLabel.leftAnchor),
            userHandleLabel.bottomAnchor.constraint(equalTo: userImageView.bottomAnchor),
            
            acceptButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            acceptButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            acceptButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            acceptButton.heightAnchor.constraint(equalToConstant: 30),
            
            ignoreButton.rightAnchor.constraint(equalTo: acceptButton.leftAnchor, constant: -24),
            ignoreButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            ignoreButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            ignoreButton.heightAnchor.constraint(equalToConstant: 30)
            
            ])
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Actions
    
    @objc func onAcceptButton(sender: AnyObject!) {
        ZMUserSession.shared()?.performChanges {
            self.user.accept()
        }
        self.acceptBlock?()
    }
    
    @objc func onIgnoreButton(sender: AnyObject!) {
        ZMUserSession.shared()?.performChanges {
            self.user.ignore()
        }
        self.ignoreBlock?()
    }

}
