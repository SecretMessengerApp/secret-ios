
import UIKit
import Cartography
import WireDataModel

protocol ConfirmEmailDelegate: class {
    func resendVerification(inController controller: ConfirmEmailViewController)
    func didConfirmEmail(inController controller: ConfirmEmailViewController)
}

extension UITableView {
    var autolayoutTableHeaderView: UIView? {
        set {
            if let newHeader = newValue {
                newHeader.translatesAutoresizingMaskIntoConstraints = false
                
                self.tableHeaderView = newHeader
                
                NSLayoutConstraint.activate([
                    newHeader.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                    newHeader.widthAnchor.constraint(equalTo: self.widthAnchor),
                    newHeader.topAnchor.constraint(equalTo: self.topAnchor)
                    ])
                
                self.tableHeaderView?.layoutIfNeeded()
                self.tableHeaderView = newHeader
            }
            else {
                self.tableHeaderView = nil
            }
        }
        get {
            return self.tableHeaderView
        }
    }
}

 final class ConfirmEmailViewController: SettingsBaseTableViewController {
    fileprivate weak var userProfile = ZMUserSession.shared()?.userProfile
    weak var delegate: ConfirmEmailDelegate?

    let newEmail: String
    fileprivate var observer: NSObjectProtocol?

    init(newEmail: String, delegate: ConfirmEmailDelegate?) {
        self.newEmail = newEmail
        self.delegate = delegate
        super.init(style: .grouped)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let userSession = ZMUserSession.shared() {
            observer = UserChangeInfo.add(observer: self, for: ZMUser.selfUser(), userSession: userSession)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observer = nil
    }

    internal func setupViews() {
        SettingsButtonCell.register(in: tableView)
        
        title = "self.settings.account_section.email.change.verify.title".localized(uppercased: true)
        view.backgroundColor = .clear
        tableView.isScrollEnabled = false
        
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 30

        let description = DescriptionHeaderView()
        description.descriptionLabel.text = "self.settings.account_section.email.change.verify.description".localized

        tableView.autolayoutTableHeaderView = description
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsButtonCell.zm_reuseIdentifier, for: indexPath) as! SettingsButtonCell
        let format = "self.settings.account_section.email.change.verify.resend".localized
        let text = String(format: format, newEmail)
        cell.titleText = text
        cell.titleColor = .black
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.resendVerification(inController: self)
        tableView.deselectRow(at: indexPath, animated: false)
        
        let message = String(format: "self.settings.account_section.email.change.resend.message".localized, newEmail)
        let alert = UIAlertController(
            title: "self.settings.account_section.email.change.resend.title".localized,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(.init(title: "general.ok".localized, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ConfirmEmailViewController: ZMUserObserver {
    func userDidChange(_ note: WireDataModel.UserChangeInfo) {
        if note.user.isSelfUser {
            // we need to check if the notification really happened because 
            // the email got changed to what we expected
            if let currentEmail = ZMUser.selfUser().emailAddress, currentEmail == newEmail {
                delegate?.didConfirmEmail(inController: self)
            }
        }
    }
}
