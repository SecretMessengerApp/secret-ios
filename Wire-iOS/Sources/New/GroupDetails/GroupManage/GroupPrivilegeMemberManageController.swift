//
//  GroupPrivilegeMemberManageController.swift
//  Wire-iOS
//

import UIKit

class GroupPrivilegeMemberManageController: UIViewController {
    
    public enum Context {
        case speaker
        case attendant 
        
        var title: String {
            switch self {
            case .speaker:
                return "conversation.setting.to.group.speaker".localized
            case .attendant:
                return "conversation.setting.to.group.attendant".localized
            }
        }
        
        var limitCount: Int {
            switch self {
            case .speaker: return .max
            case .attendant: return 10
            }
        }
    }
    
    var context: Context
    var conversation: ZMConversation
    weak var groupDetailViewController: GroupDetailsViewController?
    
    private var users: [ZMUser] = []
    
    lazy var rightBarItemButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("conversation.setting.to.group.addSpeaker".localized, for: .normal)
        btn.setTitleColor(.dynamic(scheme: .brand), for: .normal)
        btn.setTitleColor(.dynamic(scheme: .disable), for: .disabled)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        return btn
    }()
    var tableView: UITableView?
    
    init(conversation: ZMConversation, context: Context) {
        self.context = context
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureDataSource()
        self.tableView?.reloadData()
    }
    
    override func viewDidLoad() {
       title = context.title
       view.backgroundColor = .dynamic(scheme: .barBackground)
       createBackButton()
       configureTableView()
    }
    
    func createBackButton() {
        let closeImage = StyleKitIcon.backArrow.makeImage(size: .tiny, color: .black)
        let backButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(GroupPrivilegeMemberManageController.back))
        self.navigationItem.leftBarButtonItem = backButtonItem
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.rightBarItemButton)
    }
    
    func configureDataSource() {
        switch self.context {
        case .speaker :
            guard let orator = self.conversation.orator else {
                self.users = []
                return
            }
            self.users = Array(orator).compactMap {
                guard let uuid = UUID(uuidString: $0) else {return nil}
                guard let moc = self.conversation.managedObjectContext else {return nil}
                guard let user = ZMUser.init(remoteID: uuid, createIfNeeded: false, in: moc) else {return nil}
                return user
            }
        case .attendant :
            guard let managersID = self.conversation.manager else {
                self.users = []
                return
            }
            let managers: [ZMUser] = Array(managersID).compactMap {
                guard let uuid = UUID(uuidString: $0) else {return nil}
                guard let moc = self.conversation.managedObjectContext else {return nil}
                guard let user = ZMUser.init(remoteID: uuid, createIfNeeded: false, in: moc) else {return nil}
                return user
            }
            self.rightBarItemButton.isEnabled = managers.count < self.context.limitCount
            self.users = managers
        }
    }
    
    func configureTableView() {
        tableView = UITableView(frame: view.frame, style: .plain)
        tableView?.backgroundColor = .clear
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(GroupSpeakerManageCell.self, forCellReuseIdentifier: GroupSpeakerManageCell.zm_reuseIdentifier)
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        tableView?.tableFooterView = UIView()
        view.addSubview(tableView!)
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func addAction() {
        self.navigationController?.pushViewController(GroupPrivilegeMemberAddController(conversation: self.conversation,
                                                                                        context: self.context), animated: true)
    }
    
    
    
}

extension GroupPrivilegeMemberManageController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupSpeakerManageCell.zm_reuseIdentifier, for: indexPath) as! GroupSpeakerManageCell
        cell.configure(user: self.users[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = self.users[indexPath.row]
        guard let detailvc = self.groupDetailViewController else {return}
        let viewController = UserProfileViewController(
            user: user,
            connectionConversation: user.connection?.conversation,
            userProfileViewControllerDelegate: detailvc,
            groupConversation: conversation,
            isCreater: conversation.creator.isSelfUser)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "content.message.delete".localized
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        if editingStyle == .delete {
            ZMUserSession.shared()?.enqueueChanges({
                switch self.context {
                case .speaker:
                    self.conversation.orator?.remove(user.remoteIdentifier.transportString())
                case .attendant:
                    self.conversation.managerDel = [user.remoteIdentifier.transportString()]
                    self.conversation.manager?.remove(user.remoteIdentifier.transportString())
                }
            }, completionHandler: {
                self.configureDataSource()
                self.tableView?.reloadData()
            })
        }
    }
    
}

class GroupSpeakerManageCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        [nameLabel, arrow].forEach(self.contentView.addSubview)
        [nameLabel, arrow].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        arrow.setIcon(.disclosureIndicator, size: .like, color: .dynamic(scheme: .accessory))
        self.createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(user: ZMUser) {
        nameLabel.text = user.newName()
    }
    
    func createConstraints() {
        let constraints = [
            nameLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            nameLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 16),
            arrow.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            arrow.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -16)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var arrow = ThemedImageView()
}
