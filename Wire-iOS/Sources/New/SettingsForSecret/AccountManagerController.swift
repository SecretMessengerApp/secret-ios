//
//  AccountManagerController.swift
//  Wire-iOS
//

import UIKit
import Cartography
import WireDataModel

class AccountManagerController: UIViewController {
    
    private var requestController: RequestPasswordController?
    
    override func viewDidLoad() {
        self.title = "self.settings.account_manager.title".localized
        self.view.addSubview(tableView)
    }
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), style: UITableView.Style.plain)
        tableView.register(AccountManagerTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(AccountManagerTableViewCell.self))
        tableView.register(AddAcountCell.self, forCellReuseIdentifier: NSStringFromClass(AddAcountCell.self))
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.backgroundColor = UIColor.dynamic(scheme: .groupBackground)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    public func getAddaccountController() -> UIViewController? {
        let presentationAction: () -> UIViewController? = {
            if SessionManager.shared?.accountManager.accounts.count < SessionManager.maxNumberAccounts {
                SessionManager.shared?.addAccount()
            } else {
                if let controller = UIApplication.shared.topmostViewController(onlyFullScreen: false) {
                    let alert = UIAlertController(
                        title: "self.settings.add_account.error.title".localized,
                        message: "self.settings.add_account.error.message".localized,
                        alertAction: .ok(style: .cancel)
                    )
                    controller.present(alert, animated: true, completion: nil)
                }
            }
            return nil
        }
        return presentationAction()
    }
    
    
}

extension AccountManagerController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = (SessionManager.shared?.accountManager.accounts.count)! + 1
        return count > 3 ? 3 : count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell! = nil
        
        if indexPath.row == (SessionManager.shared?.accountManager.accounts.count)! {
            cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(AddAcountCell.self), for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(AccountManagerTableViewCell.self), for: indexPath)
        }
        if let acell = cell as? AccountManagerTableViewCell {
            let account = SessionManager.shared?.accountManager.accounts[indexPath.row]
            acell.accountModel = account
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == SessionManager.shared?.accountManager.accounts.count {
            guard let vc = getAddaccountController() else {return}
            self.present(vc, animated: true, completion: nil)
        } else {
            let account = SessionManager.shared?.accountManager.accounts[indexPath.row]
            SessionManager.shared?.select(account!)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == SessionManager.shared?.accountManager.accounts.count {
            return false
        }
        return true
    }
        
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "delete".localized
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let account = SessionManager.shared?.accountManager.accounts[indexPath.row]
        SessionManager.shared?.loadSession(for: account, completion: { [weak self] (session) in
            guard let `session` = session else {return}
            guard let self = self else {return}
            self.requestController = RequestPasswordController(context: .logout, callback: { [weak self] (password) in
                guard let self = self else {return}
                guard let password = password else { return }
                self.logout(password: password, session: session)
            })
            guard let controller = self.requestController else {return}
            if editingStyle == .delete {
                self.present(controller.alertController, animated: true, completion: nil)
            }
        })
    }
    
    func logout(password: String? = nil, session: ZMUserSession) {
        if let p = password {
            ZClientViewController.shared?.showLoadingView = true
            session.logout(credentials: ZMEmailCredentials(email: "", password: p), { (result) in
                ZClientViewController.shared?.showLoadingView = false
                if case .failure(let error) = result {
                    ZClientViewController.shared?.showAlert(for: error)
                }
            })
        }
    }
}


class AccountManagerTableViewCell: UITableViewCell {
    
    var accountModel: Account? {
        didSet {
            guard let account = accountModel else {return}
            nameLabel.text = account.userName
            if let imageData = account.imageData {
                userImageView.avatar = UIImage(data: imageData).map(AvatarImageView.Avatar.image)
            } else {
                let personName = PersonName.person(withName: account.userName, schemeTagger: nil)
                userImageView.avatar = .text(personName.initials)
            }
            if account.userIdentifier.uuidString == ZMUser.selfUser().remoteIdentifier?.uuidString {
                selectImageView.isHidden = false
            } else {
                selectImageView.isHidden = true
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubview(containerView)
        containerView.addSubview(userImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(selectImageView)
        self.createConstraints()
    }
    
    func createConstraints() {
        constrain(self.contentView, containerView, userImageView, nameLabel, selectImageView) { (view, containerview, userimageview, namelabel, selectimageview) in
            containerview.left == view.left
            containerview.right == view.right
            containerview.top == view.top + 10
            containerview.bottom == view.bottom
            userimageview.left == containerview.left + 16
            userimageview.top == containerview.top + 16
            userimageview.bottom == containerview.bottom - 16
            userimageview.width == 34
            userimageview.height == 34
            namelabel.left == userimageview.right + 12
            namelabel.centerY == containerview.centerY
            selectimageview.right == view.right - 16
            selectimageview.centerY == containerview.centerY
            selectimageview.width == 18
            selectimageview.height == 12
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var userImageView: UserImageView = {
        let imageView = UserImageView()
        imageView.container.backgroundColor = UIColor.lightGray
        imageView.initialsFont = .smallSemiboldFont
        imageView.initialsColor = .dynamic(scheme: .title)
        return imageView
    }()
    
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(16, .regular)
        label.textColor = UIColor.dynamic(scheme: .title)
        return label
    }()
    
    fileprivate lazy var selectImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "account_select")
        return imageView
    }()
    
    fileprivate lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.dynamic(scheme: .cellBackground)
        return view
    }()
    
}

class AddAcountCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubview(containerView)
        containerView.addSubview(addIconImageView)
        containerView.addSubview(titleLabel)
        self.createConstraints()
    }
    
    func createConstraints() {
        constrain(self.contentView, containerView, addIconImageView, titleLabel) {(view, containerview, addiconimageview, titlelabel) in
            containerview.left == view.left
            containerview.right == view.right
            containerview.top == view.top + 10
            containerview.bottom == view.bottom
            addiconimageview.left == containerview.left + 20
            addiconimageview.top == containerview.top + 20
            addiconimageview.bottom == containerview.bottom - 20
            addiconimageview.width == 24
            addiconimageview.height == 24
            titlelabel.centerY == containerview.centerY
            titlelabel.left == addiconimageview.right + 15
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var addIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "account_add")
        return imageView
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(16, .regular)
        label.textColor = UIColor.dynamic(scheme: .title)
        label.text = "self.settings.add_account.title".localized
        return label
    }()
    
    fileprivate lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.dynamic(scheme: .cellBackground)
        return view
    }()
    
}
