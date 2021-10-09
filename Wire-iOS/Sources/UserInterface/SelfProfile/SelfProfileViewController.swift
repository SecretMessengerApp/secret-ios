
import UIKit
import Cartography

extension Notification.Name {
    static let DismissSettings = Notification.Name("DismissSettings")
}

extension SelfProfileViewController: SettingsPropertyFactoryDelegate {
    func asyncMethodDidStart(_ settingsPropertyFactory: SettingsPropertyFactory) {
        self.navigationController?.topViewController?.showLoadingView = true
    }

    func asyncMethodDidComplete(_ settingsPropertyFactory: SettingsPropertyFactory) {
        self.navigationController?.topViewController?.showLoadingView = false
    }


}

final internal class SelfProfileViewController: UIViewController {
    
    static let dismissNotificationName = "SettingsNavigationControllerDismissNotificationName"
    
    private let settingsController: SettingsTableViewController
    private let accountSelectorController = AccountSelectorController()
//    private let profileContainerView = UIView()
//    private let profileView: ProfileView
    private let accountNewView = AccountNewView(user: ZMUser.selfUser())
    internal var settingsCellDescriptorFactory: SettingsCellDescriptorFactory? = nil
    internal var rootGroup: (SettingsControllerGeneratorType & SettingsInternalGroupCellDescriptorType)? = nil
    convenience init() {
        let settingsPropertyFactory = SettingsPropertyFactory(userSession: SessionManager.shared?.activeUserSession, selfUser: ZMUser.selfUser())

        let settingsCellDescriptorFactory = SettingsCellDescriptorFactory(settingsPropertyFactory: settingsPropertyFactory)
        let rootGroup = settingsCellDescriptorFactory.rootGroup()
        
        self.init(rootGroup: rootGroup)
        self.settingsCellDescriptorFactory = settingsCellDescriptorFactory
        self.rootGroup = rootGroup

        settingsPropertyFactory.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(rootGroup: SettingsControllerGeneratorType & SettingsInternalGroupCellDescriptorType) {
        settingsController = rootGroup.generateViewController()! as! SettingsTableViewController
//        profileView = ProfileView(user: ZMUser.selfUser())
        
        super.init(nibName: .none, bundle: .none)
                
//        profileView.source = self
//        profileView.imageView.addTarget(self, action: #selector(userDidTapProfileImage), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SelfProfileViewController.dismissNotification(_:)), name: NSNotification.Name.DismissSettings, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(accountNewView)
        
        accountNewView.setClickListener { [unowned self] in
            let vc = SettingsTableViewController.init(group: self.settingsCellDescriptorFactory?.accountGroup() as! SettingsInternalGroupCellDescriptorType)
//            self.navigationController?.pushViewController(vc, animated: true)
            self.wr_splitViewController?.pushToRightPossible(vc, from: self)
        }
        
        settingsController.willMove(toParent: self)
        view.addSubview(settingsController.view)
        addChild(settingsController)
        
        settingsController.view.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        settingsController.view.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        settingsController.tableView.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        settingsController.tableView.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)

        createConstraints()
        view.backgroundColor = .dynamic(scheme: .barBackground)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let tabBar = tabBarController?.tabBar, tabBar.isHidden {
            tabBarController?.tabBar.isHidden = false
        }
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func accessibilityPerformEscape() -> Bool {
        dismiss()
        return true
    }
    
    private func dismiss() {
        dismiss(animated: true)
    }
    
    @objc func dismissNotification(_ notification: NSNotification) {
        dismiss()
    }
    
    private func createCloseButton() {
        navigationItem.rightBarButtonItem = navigationController?.closeItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !presentNewLoginAlertControllerIfNeeded() {
            presentUserSettingChangeControllerIfNeeded()
        }
    }

    private func configureAccountTitle() {
        if SessionManager.shared?.accountManager.accounts.count > 1 {
            navigationItem.titleView = accountSelectorController.view
        } else {
            title = "self.account".localized.uppercased()
        }
    }
    
    private func createConstraints() {
        accountNewView.translatesAutoresizingMaskIntoConstraints = false
        settingsController.view.translatesAutoresizingMaskIntoConstraints = false
        settingsController.tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [
                accountNewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                accountNewView.topAnchor.constraint(equalTo: view.topAnchor),
                accountNewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                accountNewView.heightAnchor.constraint(equalToConstant: 100),

                settingsController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                settingsController.view.topAnchor.constraint(equalTo: accountNewView.bottomAnchor),
                settingsController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                settingsController.view.bottomAnchor.constraint(equalTo: safeBottomAnchor),
            
            ] + settingsController.tableView.edgesToSuperviewEdges()
        )
    }
    
    @objc func userDidTapProfileImage(sender: UserImageView) {
        let profileImageController = ProfileSelfPictureViewController(context: .selfUser(ZMUser.selfUser()?.imageMediumData))
        self.present(profileImageController, animated: true, completion: .none)
    }
}
