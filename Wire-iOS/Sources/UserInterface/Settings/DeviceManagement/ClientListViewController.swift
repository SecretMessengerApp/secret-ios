

import UIKit


private let zmLog = ZMSLog(tag: "UI")

final class ClientListViewController: UIViewController,
                                UITableViewDelegate,
                                UITableViewDataSource,
                                ZMClientUpdateObserver,
                                ClientColorVariantProtocol {
    var removalObserver: ClientRemovalObserver?
    
    var clientsTableView: UITableView?
    let topSeparator = OverflowSeparatorView()
    weak var delegate: ClientListViewControllerDelegate?

    var variant: ColorSchemeVariant? {
        didSet {
            setColor(for: variant)
        }
    }

    var editingList: Bool = false {
        didSet {
            guard clients.count > 0 else {
                self.navigationItem.rightBarButtonItem = nil
                self.navigationItem.setHidesBackButton(false, animated: true)
                return
            }

            createRightBarButtonItem()

            self.navigationItem.setHidesBackButton(self.editingList, animated: true)

            self.clientsTableView?.setEditing(self.editingList, animated: true)
        }
    }

    var clients: [UserClient] = [] {
        didSet {
            self.sortedClients = self.clients.filter(clientFilter).sorted(by: clientSorter)
            self.clientsTableView?.reloadData();

            if clients.count > 0 {
                createRightBarButtonItem()
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }

    private let clientSorter: (UserClient, UserClient) -> Bool
    private let clientFilter: (UserClient) -> Bool

    var sortedClients: [UserClient] = []
    
    let selfClient: UserClient?
    let detailedView: Bool
    var credentials: ZMEmailCredentials?
    var clientsObserverToken: Any?
    var userObserverToken : NSObjectProtocol?
    
    var leftBarButtonItem: UIBarButtonItem? {
//        if self.isIPadRegular() {
//            return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ClientListViewController.backPressed(_:)))
//        }

        if let rootViewController = self.navigationController?.viewControllers.first,
            self.isEqual(rootViewController) {
            return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ClientListViewController.backPressed(_:)))
        }

        return nil
    }

    required init(clientsList: [UserClient]?,
                  selfClient: UserClient? = ZMUserSession.shared()?.selfUserClient(),
                  credentials: ZMEmailCredentials? = .none,
                  detailedView: Bool = false,
                  showTemporary: Bool = true,
                  showLegalHold: Bool = true,
                  variant: ColorSchemeVariant? = .none) {
        self.selfClient = selfClient
        self.detailedView = detailedView
        self.credentials = credentials
        defer {
            self.variant = variant
        }

        clientFilter = { $0 != selfClient && (showTemporary || !$0.isTemporary) }
        clientSorter = {
            guard let leftDate = $0.activationDate, let rightDate = $1.activationDate else { return false }
            return leftDate.compare(rightDate) == .orderedDescending
        }

        super.init(nibName: nil, bundle: nil)
        title = "registration.devices.title".localized(uppercased: true)

        self.initalizeProperties(clientsList ?? Array(ZMUser.selfUser().clients.filter { !$0.isSelfClient() } ))
        self.clientsObserverToken = ZMUserSession.shared()?.add(self)
        if let user = ZMUser.selfUser(), let session = ZMUserSession.shared() {
            self.userObserverToken = UserChangeInfo.add(observer: self, for: user, userSession: session)
        }
        
        if clientsList == nil {
            if clients.isEmpty {
                self.showLoadingView = true
            }
            ZMUserSession.shared()?.fetchAllClients()
        }
    }
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibNameOrNil:nibBundleOrNil:) has not been implemented")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initalizeProperties(_ clientsList: [UserClient]) {
        self.clients = clientsList
        self.editingList = false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.portrait]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.createTableView()
        self.view.addSubview(self.topSeparator)
        self.createConstraints()

        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.clientsTableView?.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        showLoadingView = false
    }

    func openDetailsOfClient(_ client: UserClient) {
        if let navigationController = self.navigationController {
            let clientViewController = SettingsClientViewController(userClient: client, credentials: self.credentials, variant: variant)
            clientViewController.view.backgroundColor = self.view.backgroundColor
            navigationController.pushViewController(clientViewController, animated: true)
        }
    }

    fileprivate func createTableView() {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped);
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.register(ClientTableViewCell.self, forCellReuseIdentifier: ClientTableViewCell.zm_reuseIdentifier)
        tableView.isEditing = self.editingList
        tableView.backgroundColor = UIColor.dynamic(scheme: .groupBackground)
        tableView.separatorColor = separatorColor
        self.view.addSubview(tableView)
        self.clientsTableView = tableView
    }
    
    fileprivate func createConstraints() {
        guard let clientsTableView = clientsTableView else {
            return
        }

        clientsTableView.translatesAutoresizingMaskIntoConstraints = false

        clientsTableView.fitInSuperview(safely: true)
    }
    
    fileprivate func convertSection(_ section: Int) -> Int {
        if let _ = self.selfClient {
            return section
        }
        else {
            return section + 1
        }
    }
    
    // MARK: - Actions
    
    @objc func startEditing(_ sender: AnyObject!) {
        self.editingList = true
    }
    
    @objc func endEditing(_ sender: AnyObject!) {
        self.editingList = false
    }
    
    @objc func backPressed(_ sender: AnyObject!) {
        self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    func deleteUserClient(_ userClient: UserClient, credentials: ZMEmailCredentials?) {
        removalObserver = nil
        
        removalObserver = ClientRemovalObserver(userClientToDelete: userClient,
                                                controller: self,
                                                credentials: credentials)
        
        removalObserver?.userClientToDelete = userClient
        removalObserver?.credentials = credentials
        removalObserver?.startRemoval()
        
//        delegate?.finishedDeleting(self)
    }
    
    // MARK: - ZMClientRegistrationObserver

    func finishedFetching(_ userClients: [UserClient]) {
        self.showLoadingView = false
        
        self.clients = userClients.filter { !$0.isSelfClient() }
    }
    
    func failedToFetchClientsWithError(_ error: Error) {
        self.showLoadingView = false
        
        zmLog.error("Clients request failed: \(error.localizedDescription)")
        
        presentAlertWithOKButton(message: "error.user.unkown_error".localized)
    }
    
    func finishedDeleting(_ remainingClients: [UserClient]) {
        clients = remainingClients
        
        editingList = false
        
        delegate?.finishedDeleting(self)
    }
    
    func failedToDeleteClientsWithError(_ error: Error) {
        self.showLoadingView = false
        
        self.showAlert(for: NSError(domain: NSError.ZMUserSessionErrorDomain, code: Int(ZMUserSessionErrorCode.invalidCredentials.rawValue), userInfo: nil))
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = self.selfClient , self.sortedClients.count > 0 {
            return 2
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.convertSection(section) {
        case 0:
            if let _ = self.selfClient {
                return 1
            }
            else {
                return 0
            }
        case 1:
            return self.sortedClients.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch self.convertSection(section) {
            case 0:
                if let _ = self.selfClient {
                    return NSLocalizedString("registration.devices.current_list_header", comment:"")
                }
                else {
                    return nil
                }
            case 1:
                return NSLocalizedString("registration.devices.active_list_header", comment:"")
            default:
                return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch self.convertSection(section) {
            case 0:
                return nil
            case 1:
                return NSLocalizedString("registration.devices.active_list_subtitle", comment:"")
            default:
                return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerFooterView = view as? UITableViewHeaderFooterView {
            headerFooterView.textLabel?.textColor = UIColor.dynamic(scheme: .subtitle)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let headerFooterView = view as? UITableViewHeaderFooterView {
            headerFooterView.textLabel?.textColor = UIColor.dynamic(scheme: .subtitle)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ClientTableViewCell.zm_reuseIdentifier, for: indexPath) as? ClientTableViewCell {
            cell.selectionStyle = .none
            cell.accessoryType = self.detailedView ? .disclosureIndicator : .none
            cell.showVerified = self.detailedView
            cell.variant = variant
            
            switch self.convertSection((indexPath as NSIndexPath).section) {
            case 0:
                cell.userClient = self.selfClient
                cell.wr_editable = false
                cell.showVerified = false
            case 1:
                cell.userClient = self.sortedClients[indexPath.row]
                cell.wr_editable = true
            default:
                cell.userClient = nil
            }
            
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch self.convertSection((indexPath as NSIndexPath).section) {
        case 1:
            
            let userClient = self.sortedClients[indexPath.row]
            
            if let password = credentials?.password, !password.isEmpty {
                self.deleteUserClient(userClient, credentials: credentials)
            } else {
                requestPassword { (credential) in
                    self.deleteUserClient(userClient, credentials: credential)
                }
            }
        default: break
        }
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        switch self.convertSection((indexPath as NSIndexPath).section) {
        case 0:
            return .none
        case 1:
            return .delete
        default:
            return .none
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.detailedView {
            return
        }
        switch self.convertSection((indexPath as NSIndexPath).section) {
        case 0:
            if let selfClient = self.selfClient {
                self.openDetailsOfClient(selfClient)
            }
            break;
        case 1:
            self.openDetailsOfClient(self.sortedClients[indexPath.row])
            break;
        default:
            break;
        }

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.topSeparator.scrollViewDidScroll(scrollView: scrollView)
    }

    func createRightBarButtonItem() {
        if (self.editingList) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "general.done".localized.localizedUppercase, style: .plain, target: self, action: #selector(ClientListViewController.endEditing(_:)))

            self.navigationItem.setLeftBarButton(nil, animated: true)
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "general.edit".localized.localizedUppercase, style: .plain, target: self, action: #selector(ClientListViewController.startEditing(_:)))

            self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: true)
        }
    }
}

extension ClientListViewController : ZMUserObserver {
    
    func userDidChange(_ note: UserChangeInfo) {
        if (note.clientsChanged || note.trustLevelChanged) {
            guard let selfClient = ZMUser.selfUser().selfClient() else { return }
            var clients = ZMUser.selfUser().clients
            clients.remove(selfClient)
            self.clients = Array(clients)
        }
    }
    
}

fileprivate extension UserClient {

    var isTemporary: Bool {
        return type.rawValue == "temporary"
    }

}
