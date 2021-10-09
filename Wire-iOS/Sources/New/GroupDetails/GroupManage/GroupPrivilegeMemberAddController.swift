//
//  GroupPrivilegeMemberAddController.swift
//  Wire-iOS
//

import UIKit
import SwiftyJSON

class GroupPrivilegeMemberAddController: UIViewController {
    
    var conversation: ZMConversation
    var context: GroupPrivilegeMemberManageController.Context
    
    var tableView: UITableView! = nil
    
    var tokenField: TokenField! = nil
    
    let tokenFieldContainer = UIView()
    let searchIcon = ThemedImageView()
    let clearButton: IconButton
    
    var users: [SearchUserValue] = []
        
    init(conversation: ZMConversation, context: GroupPrivilegeMemberManageController.Context) {
        self.context = context
        self.conversation = conversation
        self.clearButton = IconButton(style: .default, variant: .light)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        title = "conversation.setting.to.group.addSpeaker".localized
        view.backgroundColor = .dynamic(scheme: .barBackground)
        createBackButton()
        createSearchTextField()
        configureTableView()
        createConstraints()
    }
    
    func createBackButton() {
        let closeImage = StyleKitIcon.backArrow.makeImage(size: .tiny, color: .black)
        let backButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(GroupPrivilegeMemberAddController.back))
        self.navigationItem.leftBarButtonItem = backButtonItem
    }
    
    func createSearchTextField() {
        searchIcon.image = StyleKitIcon.search.makeImage(size: .tiny, color: .dynamic(scheme: .iconNormal))
        
        clearButton.accessibilityLabel = "clear"
        clearButton.setIcon(.clearInput, size: .tiny, for: .normal)
        clearButton.addTarget(self, action: #selector(onClearButtonPressed), for: .touchUpInside)
        clearButton.alpha = 0.4
        clearButton.isHidden = true
        
        tokenField = TokenField()
        tokenField.layer.cornerRadius = 20
        tokenField.textColor = .dynamic(scheme: .title)
        tokenField.tokenTitleColor = .dynamic(scheme: .title)
        tokenField.tokenSelectedTitleColor = .dynamic(scheme: .title)
        tokenField.clipsToBounds = true
        tokenField.textView.placeholderTextColor = .dynamic(scheme: .placeholder)
        tokenField.textView.backgroundColor = .dynamic(scheme: .inputBackground)
        tokenField.textView.accessibilityIdentifier = "textViewSearch"
        tokenField.textView.placeholder = "peoplepicker.search_placeholder".localized.uppercased()
        tokenField.textView.returnKeyType = .search
        tokenField.textView.autocorrectionType = .no
        tokenField.textView.textContainerInset = UIEdgeInsets(top: 9, left: 40, bottom: 11, right: 32)
        tokenField.delegate = self
        [tokenField, searchIcon, clearButton].forEach(tokenFieldContainer.addSubview)
        [tokenFieldContainer].forEach(view.addSubview)
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        tokenField.translatesAutoresizingMaskIntoConstraints = false
        tokenFieldContainer.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GroupSpeakerAddManageCell.self, forCellReuseIdentifier: GroupSpeakerAddManageCell.zm_reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
    }
    
    func createConstraints() {
        let constraints = [
            tokenFieldContainer.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8),
            tokenFieldContainer.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 8),
            tokenFieldContainer.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -8),
            tokenFieldContainer.heightAnchor.constraint(equalToConstant: 56),
            searchIcon.leftAnchor.constraint(equalTo: tokenFieldContainer.leftAnchor, constant: 16),
            searchIcon.centerYAnchor.constraint(equalTo: tokenFieldContainer.centerYAnchor),
            clearButton.centerYAnchor.constraint(equalTo: tokenFieldContainer.centerYAnchor),
            clearButton.heightAnchor.constraint(equalTo: clearButton.heightAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 32),
            clearButton.rightAnchor.constraint(equalTo: tokenFieldContainer.rightAnchor, constant: -8),
            tokenField.topAnchor.constraint(greaterThanOrEqualTo: tokenFieldContainer.topAnchor, constant: 8),
            tokenField.bottomAnchor.constraint(lessThanOrEqualTo: tokenFieldContainer.bottomAnchor, constant: -8),
            tokenField.leftAnchor.constraint(equalTo: tokenFieldContainer.leftAnchor, constant: 8),
            tokenField.rightAnchor.constraint(equalTo: tokenFieldContainer.rightAnchor, constant: -8),
            tokenField.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            tokenField.centerYAnchor.constraint(equalTo: tokenFieldContainer.centerYAnchor),
            tableView.topAnchor.constraint(equalTo: self.tokenFieldContainer.bottomAnchor, constant: 16),
            tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func addAction(with userid: String) {
        ZMUserSession.shared()?.enqueueChanges({
            switch self.context {
            case .speaker:
                if let or = self.conversation.orator {
                    self.conversation.orator = or.union([userid])
                } else {
                    self.conversation.orator = [userid]
                }
            case .attendant:
                if let or = self.conversation.manager {
                    self.conversation.manager = or.union([userid])
                } else {
                    self.conversation.manager = [userid]
                }
                self.conversation.managerAdd = [userid]
            }
        }, completionHandler: {
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    @objc func onClearButtonPressed() {
        
    }
    
}

extension GroupPrivilegeMemberAddController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupSpeakerAddManageCell.zm_reuseIdentifier, for: indexPath) as! GroupSpeakerAddManageCell
        let user = users[indexPath.row]
        cell.configure(user: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = users[indexPath.row]
        guard let userid = user.id else {return}
        self.addAction(with: userid)
    }
    
}

extension GroupPrivilegeMemberAddController: TokenFieldDelegate {
    
    func tokenField(_ tokenField: TokenField, changedTokensTo tokens: [Token<NSObjectProtocol>]) {
        // no-op
    }
    
    func tokenField(_ tokenField: TokenField, changedFilterTextTo text: String) {
        // no-op
    }
    
    func tokenFieldDidConfirmSelection(_ controller: TokenField) {
        GroupManageSearchUserService.getUsers(convid: self.conversation.remoteIdentifier?.transportString(), searchValue: tokenField.textView.text) { (result) in
            switch result {
            case .failure:
                break
            case .success(let value):
                self.users = value.filter {
                    if $0.id == ZMUser.selfUser()?.remoteIdentifier.transportString() {
                        return false
                    }
                    switch self.context {
                    case .speaker:
                        if let orator = self.conversation.orator, let userId = $0.id {
                            return !orator.contains(userId)
                        } else {
                            return true
                        }
                    case .attendant:
                        if let manager = self.conversation.manager, let userId = $0.id {
                            return !manager.contains(userId)
                        } else {
                            return true
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
}

struct SearchUserValue {
    var name: String?
    var handle: String?
    var id: String?
    var asset: String?
    
    init(json: JSON) {
        name = json["name"].stringValue
        handle = json["handle"].stringValue
        id = json["id"].stringValue
        asset = json["asset"].stringValue
    }
}

class GroupSpeakerAddManageCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        [headerImageView, nameLabel, handlerLabel].forEach(self.contentView.addSubview)
        [headerImageView, nameLabel, handlerLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        self.createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(user: SearchUserValue?) {
        guard let value = user else {return}
        nameLabel.text = value.name
        handlerLabel.text = "@" + (value.handle ?? "")
        headerImageView.setImage(placeHolder: UIImage.init(named: "head_default"), key: value.asset, userid: user?.id)
    }
    
    func createConstraints() {
        let constraints = [
            headerImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            headerImageView.heightAnchor.constraint(equalTo: headerImageView.widthAnchor),
            headerImageView.widthAnchor.constraint(equalToConstant: 40),
            headerImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 16),
            nameLabel.leftAnchor.constraint(equalTo: headerImageView.rightAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            handlerLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            handlerLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor, constant: -12)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .dynamic(scheme: .title)
        return label
    }()
    
    private lazy var handlerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .dynamic(scheme: .subtitle)
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private lazy var headerImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.layer.cornerRadius = 20
        imageview.clipsToBounds = true
        return imageview
    }()
}


private class GroupManageSearchUserService: NetworkRequest {
    
    class func getUsers(convid: String?, searchValue: String?, completion: @escaping (BaseResult<[SearchUserValue], String>) -> Void) {
        guard let cid = convid, let name = searchValue else {return}
        let url = API.Base.backend + API.Conversation.conversations + "/\(cid)" + "/search?q=" + name + "&size=100"
        request(url).responseData { (response) in
            switch response.result {
            case .failure(let err): completion(.failure(err.localizedDescription))
            case .success(let data):
                let json = try? JSON(data: data)
                let items = json?.array?.map { SearchUserValue(json: $0) }
                completion(.success(items ?? []))
            }
        }
    }
}

extension UIImageView {
    //secret
    public func setImage(placeHolder: UIImage?, key: String?, userid: String? = nil) {
        if let id = userid, let uuid = UUID(uuidString: id), let user = ZMUser(remoteID: uuid, createIfNeeded: false, in: ZMUserSession.shared()?.managedObjectContext), let data = user.imageSmallProfileData {
            self.image = UIImage(data: data)
            return
        }
        guard let manageObjectContext = ZMUserSession.shared()?.syncManagedObjectContext!, let keyValue = key else {return}
        if let place  = placeHolder {
            self.image = place
        }
        let path = NSString.path(withComponents: ["/assets/v3", keyValue])
        let request = ZMTransportRequest(path: path, method: .methodGET, payload: nil, authentication: .needsAccess)
        request.add(ZMCompletionHandler(on: manageObjectContext, block: { (response) in
            guard let data = response.rawData else {return}
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }))
        ZMUserSession.shared()?.transportSession.enqueueOneTime(request)
    }
    
}
