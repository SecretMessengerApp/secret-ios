

import UIKit

private let zmLog = ZMSLog(tag: "UI")

enum ClientSection: Int {
    case info = 0
    case fingerprintAndVerify = 1
    case resetSession = 2
    case removeDevice = 3
}

class SettingsClientViewController: UIViewController,
                                    UITableViewDelegate,
                                    UITableViewDataSource,
                                    UserClientObserver,
                                    ClientColorVariantProtocol {
    
    fileprivate static let deleteCellReuseIdentifier: String = "DeleteCellReuseIdentifier"
    fileprivate static let resetCellReuseIdentifier: String = "ResetCellReuseIdentifier"
    fileprivate static let verifiedCellReuseIdentifier: String = "VerifiedCellReuseIdentifier"
    
    let userClient: UserClient
    var resetSessionPending: Bool = false
    
    var userClientToken: NSObjectProtocol!
    var credentials: ZMEmailCredentials?

    var tableView: UITableView!
    
    var fromConversation : Bool = false

    var variant: ColorSchemeVariant? {
        didSet {
            setColor(for: variant)
        }
    }
    
    var removalObserver: ClientRemovalObserver?

    convenience init(userClient: UserClient,
                     fromConversation: Bool,
                     credentials: ZMEmailCredentials? = .none,
                     variant: ColorSchemeVariant? = .none) {
        self.init(userClient: userClient, credentials: credentials, variant: variant)
        self.fromConversation = fromConversation
    }
    
    required init(userClient: UserClient,
                  credentials: ZMEmailCredentials? = .none,
                  variant: ColorSchemeVariant? = .none) {
        self.userClient = userClient
        defer {
            self.variant = variant
        }

        super.init(nibName: nil, bundle: nil)
        self.edgesForExtendedLayout = []

        self.userClientToken = UserClientChangeInfo.add(observer: self, for: userClient)
        if userClient.fingerprint == .none {
            ZMUserSession.shared()?.enqueueChanges({ () -> Void in
                userClient.fetchFingerprintOrPrekeys()
            })
        }
        self.title = userClient.deviceClass?.localizedDescription.localizedUppercase
        self.credentials = credentials
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTableView()
        createConstraints()

        if fromConversation {
            setupFromConversationStyle()
        }
    }

    func setupFromConversationStyle() {
        view.backgroundColor = .dynamic(scheme: .background)
        tableView.separatorColor = .dynamic(scheme: .separator)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // presented modally from conversation
        if let navController = self.navigationController,
            navController.viewControllers.count > 0 &&
            navController.viewControllers[0] == self,
            navigationItem.rightBarButtonItem == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDonePressed))
        }
    }
    
    fileprivate func createTableView() {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.backgroundColor = .dynamic(scheme: .groupBackground)
        tableView.separatorColor = separatorColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ClientTableViewCell.self, forCellReuseIdentifier: ClientTableViewCell.zm_reuseIdentifier)
        tableView.register(FingerprintTableViewCell.self, forCellReuseIdentifier: FingerprintTableViewCell.zm_reuseIdentifier)
        tableView.register(SettingsTableCell.self, forCellReuseIdentifier: type(of: self).deleteCellReuseIdentifier)
        tableView.register(SettingsTableCell.self, forCellReuseIdentifier: type(of: self).resetCellReuseIdentifier)
        tableView.register(SettingsToggleCell.self, forCellReuseIdentifier: type(of: self).verifiedCellReuseIdentifier)
        self.tableView = tableView
        self.view.addSubview(tableView)
    }
    
    private func createConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibNameOrNil:nibBundleOrNil:) has not been implemented")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onVerifiedChanged(_ sender: UISwitch!) {
        let selfClient = ZMUserSession.shared()!.selfUserClient()
        
        ZMUserSession.shared()?.enqueueChanges({
            if (sender.isOn) {
                selfClient?.trustClient(self.userClient)
            } else {
                selfClient?.ignoreClient(self.userClient)
            }
        }, completionHandler: {
            sender.isOn = self.userClient.verified
        })
    }
    
    @objc func onDonePressed(_ sender: AnyObject!) {
        self.navigationController?.presentingViewController?.dismiss(animated: true, completion: .none)
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let userClient = ZMUserSession.shared()?.selfUserClient(), self.userClient == userClient {
            return 2
        } else {
            return userClient.type == .legalHold ? 3 : 4
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let clientSection = ClientSection(rawValue: section) else { return 0 }
        switch clientSection {
            
        case .info:
            return 1
        case .fingerprintAndVerify:
            if self.userClient == ZMUserSession.shared()?.selfUserClient()  {
                return 1
            }
            else {
                return 2
            }
        case .resetSession:
            return 1
        case .removeDevice:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let clientSection = ClientSection(rawValue: (indexPath as NSIndexPath).section) else { return UITableViewCell() }

        switch clientSection {
            
        case .info:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ClientTableViewCell.zm_reuseIdentifier, for: indexPath) as? ClientTableViewCell {
                cell.selectionStyle = .default
                cell.userClient = self.userClient
                cell.wr_editable = false
                cell.showVerified = false
                cell.showLabel = true
                cell.variant = self.variant
                return cell
            }

            break
        
        case .fingerprintAndVerify:
            if (indexPath as NSIndexPath).row == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: FingerprintTableViewCell.zm_reuseIdentifier, for: indexPath) as? FingerprintTableViewCell {
                    cell.fingerprint = self.userClient.fingerprint
                    return cell
                }
            }
            else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self).verifiedCellReuseIdentifier, for: indexPath) as? SettingsToggleCell {
                    cell.titleText = NSLocalizedString("device.verified", comment: "")
                    cell.cellNameLabel.accessibilityIdentifier = "device verified label"
                    cell.switchView.addTarget(self, action: #selector(SettingsClientViewController.onVerifiedChanged(_:)), for: .touchUpInside)
                    cell.switchView.accessibilityIdentifier = "device verified"
                    cell.accessibilityIdentifier = "device verified"
                    cell.switchView.isOn = self.userClient.verified
                        cell.variant = self.variant
                    return cell
                }
            }
            break
        case .resetSession:
            if let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self).resetCellReuseIdentifier, for: indexPath) as? SettingsTableCell {
                cell.titleText = NSLocalizedString("profile.devices.detail.reset_session.title", comment: "")
                cell.accessibilityIdentifier = "reset session"
                cell.variant = self.variant
                return cell
            }
            
            break
        case .removeDevice:
            if let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self).deleteCellReuseIdentifier, for: indexPath) as? SettingsTableCell {
                cell.titleText = NSLocalizedString("self.settings.account_details.remove_device.title", comment: "")
                cell.accessibilityIdentifier = "remove device"
                cell.variant = self.variant
                return cell
            }
            
            break
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let clientSection = ClientSection(rawValue: (indexPath as NSIndexPath).section) else { return }

        switch clientSection {
        case .resetSession:
            self.userClient.resetSession()
            self.resetSessionPending = true
            break
            
        case .removeDevice:
            removalObserver = nil

            func removeDevice(with credentials: ZMEmailCredentials) {
                let completion: ((Error?)->()) = { error in
                    if error == nil {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
                removalObserver = ClientRemovalObserver(userClientToDelete: userClient,
                                                        controller: self,
                                                        credentials: credentials, completion: completion)
                
                
                removalObserver?.startRemoval()
            }
            
            if let password = credentials?.password, !password.isEmpty {
                removeDevice(with: credentials!)
            } else {
                requestPassword { (credential) in
                    if let credential = credential {
                        removeDevice(with: credential)
                    }
                }
            }

        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("self.settings.account_details.equipment_model.title", comment: "")
        case 1:
            return NSLocalizedString("self.settings.account_details.key_fingerprint.title", comment: "")
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let clientSection = ClientSection(rawValue: section) else { return .none }
        switch clientSection {
           
        case .fingerprintAndVerify:
            return NSLocalizedString("self.settings.device_details.fingerprint.subtitle", comment: "")
        case .resetSession:
            return NSLocalizedString("self.settings.device_details.reset_session.subtitle", comment: "")
        case .removeDevice:
            return NSLocalizedString("self.settings.device_details.remove_device.subtitle", comment: "")
            
        default:
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerFooterView = view as? UITableViewHeaderFooterView {
            headerFooterView.textLabel?.textColor = UIColor.dynamic(scheme: .note)
        }
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let headerFooterView = view as? UITableViewHeaderFooterView {
            headerFooterView.textLabel?.textColor = .dynamic(scheme: .note)
        }
    }

    // MARK: - Copying user client info

    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == ClientSection.info.rawValue && indexPath.row == 0 {
            return true
        } else {
            return false
        }
    }

    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {

        if action == #selector(UIResponder.copy(_:)) {
            return true
        } else {
            return false
        }
    }

    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(UIResponder.copy(_:)) {
            UIPasteboard.general.string = self.userClient.information
        }
    }

    // MARK: - UserClientObserver
    
    func userClientDidChange(_ changeInfo: UserClientChangeInfo) {
        if let tableView = self.tableView {
            tableView.reloadData()
        }
        
        // This means the fingerprint is acquired
        if self.resetSessionPending && self.userClient.fingerprint != .none {
            let alert = UIAlertController(title: "", message: NSLocalizedString("self.settings.device_details.reset_session.success", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("general.ok", comment: ""), style: .default, handler:  { [unowned alert] (_) -> Void in
                alert.dismiss(animated: true, completion: .none)
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: .none)
            self.resetSessionPending = false
        }
    }
}

extension UserClient {
    var information: String {
        var lines = [String]()
        if let model = model {
            lines.append("Device: \(model)")
        }
        if let remoteIdentifier = remoteIdentifier {
            lines.append("ID: \(remoteIdentifier)")
        }
        if let pushToken = pushToken {
            lines.append("Push Token: \(pushToken.deviceTokenString)")
        }
        return lines.joined(separator: "\n")
    }
}
