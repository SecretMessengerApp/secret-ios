//
//  GroupInvitedConfirmController.swift
//  Wire-iOS
//

import UIKit
import SwiftyJSON

class GroupInvitedConfirmController: UIViewController {
    
    public enum Context {
        case creatorConfirm(ZMMessage?)
        case userConfirm(ZMMessage?)
        
        var title: String {
            switch self {
            case .creatorConfirm:
                return "conversation.group_invite.vc.nav.title".localized
            case .userConfirm:
                return "conversation.groupinvite.add.self.title".localized
            }
        }
        
    }
    
    typealias DismissListener = () -> Void
    fileprivate lazy var collectionV: UICollectionView = {
        let layout = GroupInviteCollectionViewlayout()
        layout.itemSize = CGSize(width: 47, height: 64)
        let collectionV = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionV.delegate = self
        collectionV.dataSource = self
        collectionV.backgroundColor = .dynamic(scheme: .cellBackground)
        return collectionV
    }()
    fileprivate lazy var memberV = GroupMemberInvitedView()
    fileprivate lazy var btnsV = GroupAddConfirmBtnsView()

    fileprivate var conversation: ZMConversation?
    fileprivate var context: Context
    fileprivate var datasource: [ZMUser] = [ZMUser]()
    var dismissListener: DismissListener?

    public init(conversation: ZMConversation?, context: Context) {
        self.conversation = conversation
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.title = context.title
        configUI()
        configData()
    }

    @objc private func confirmAction() {
        
        switch context {
        case .creatorConfirm(let message):
            guard let cnv = self.conversation, let msg = message else { return }
            guard let originStr = msg.jsonTextMessageData?.jsonMessageText else { return }
            let dictionary = JSON(parseJSON: originStr)
            guard let code = dictionary["msgData"]["code"].string else { return }
            HUD.loading()
            GroupManageService.creatorVerify(cnvId: cnv.remoteIdentifier?.transportString() ?? "", code: code, allow: true) { (result) in
                HUD.hide()
                switch result {
                case .success:
                    self.dismissListener?()
                    self.dismiss(animated: true, completion: nil)
                case .failure(let err):
                    HUD.error(err.description)
                }
            }
        case .userConfirm(let message):
            guard let msg = message, let originStr = msg.jsonTextMessageData?.jsonMessageText else { return }
            let dictionary = JSON(parseJSON: originStr)
            guard let groupid = dictionary["msgData"]["conversationId"].string else { return }
            guard let cnv = self.conversation, let sender = cnv.firstActiveParticipantOtherThanSelf else { return }
            HUD.loading()
            GroupManageService.beJoin(id: groupid, inviteid: sender.remoteIdentifier.transportString()) { (result) in
                HUD.hide()
                switch result {
                case .success:
                    ZMUserSession.shared()?.enqueueChanges({
                        message?.isGet = true
                    }, completionHandler: {
                        self.dismissListener?()
                        self.dismiss(animated: true, completion: nil)
                    })
                case .failure(let err):
                    HUD.error(err.description)
                }
            }
        }
    }
    
    @objc fileprivate func refuseAction() {
         if case Context.userConfirm(let message) = context {
            ZMUserSession.shared()?.enqueueChanges({
                message?.isRefuse = true
                message?.isGet = true
            }, completionHandler: {
                self.dismissListener?()
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
        
    fileprivate func configUI() {
        
        view.backgroundColor = .dynamic(scheme: .groupBackground)
        navigationItem.rightBarButtonItem = navigationController?.closeItem()
        
        view.addSubview(memberV)
        memberV.confirmBtn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        memberV.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            memberV.leftAnchor.constraint(equalTo: view.leftAnchor),
            memberV.rightAnchor.constraint(equalTo: view.rightAnchor),
            memberV.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        switch context {
        case .creatorConfirm:
            view.addSubview(collectionV)
            collectionV.translatesAutoresizingMaskIntoConstraints = false
            collectionV.register(GroupUrlShareCollectionCell.self, forCellWithReuseIdentifier: "ParticipantsListCellID")
            NSLayoutConstraint.activate([
                collectionV.leftAnchor.constraint(equalTo: view.leftAnchor),
                collectionV.rightAnchor.constraint(equalTo: view.rightAnchor),
                collectionV.topAnchor.constraint(equalTo: memberV.bottomAnchor),
                collectionV.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

        case .userConfirm:
            view.addSubview(btnsV)
            btnsV.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                btnsV.leftAnchor.constraint(equalTo: view.leftAnchor),
                btnsV.rightAnchor.constraint(equalTo: view.rightAnchor),
                btnsV.topAnchor.constraint(equalTo: memberV.bottomAnchor, constant: 10),
                btnsV.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            btnsV.joinBtn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
            btnsV.refuseBtn.addTarget(self, action: #selector(refuseAction), for: .touchUpInside)
            
        }
        
    }
    
    fileprivate func configData() {

        switch context {
        case .creatorConfirm(let message):
            guard let msg = message, let originStr = msg.jsonTextMessageData?.jsonMessageText else { return }
            let dictionary = JSON(parseJSON: originStr)
            
            if let inviter = dictionary["msgData"]["type"].int, inviter == 2 {
                memberV.confirmBtn.isEnabled = false
                memberV.confirmBtn.setTitle("conversation.groupinvite.done".localized, for: .normal)
            } else {
                memberV.confirmBtn.isEnabled = true
                memberV.confirmBtn.setTitle("conversation.groupinvite.confirm.invite".localized, for: .normal)
            }

            self.memberV.configUser(inviterId: dictionary["msgData"]["inviter"].stringValue, reason:dictionary["msgData"]["reason"].stringValue, nums: dictionary["msgData"]["nums"].intValue)

            if let users = dictionary["msgData"]["users"].array {
                users.forEach { item in
                    ZMUser.createUserIfNeededWithRemoteID(item["id"].stringValue, complete: { (user) in
                        if let user = user {
                            self.datasource.append(user)
                            self.collectionV.reloadData()
                        }
                    })
                }
                self.collectionV.reloadData()
            }
        case .userConfirm(let message):
            guard let msg = message else {return}
            self.btnsV.configTitle(title: message?.sender?.newName() ?? "")
            var status = GroupInvitedConfirmController.GroupAddConfirmBtnsView.Status.default
            if msg.isGet && msg.isRefuse {
                status = .refuse
            } else if msg.isGet {
                status = .join
            } else {
                status = .default
            }
            guard let originStr = msg.jsonTextMessageData?.jsonMessageText else { return }
            let dictionary = JSON(parseJSON: originStr)
            self.memberV.configUser(inviterId: dictionary["msgData"]["name"].stringValue,
                                    reason: "",
                                    nums: dictionary["msgData"]["memberCount"].intValue,
                                    asset: dictionary["msgData"]["asset"].stringValue,
                                    isUserConfirm: true,
                                    conversationId: dictionary["msgData"]["conversationId"].stringValue)
            self.btnsV.configStatus(status: status)
        }
    }
    
    class GroupMemberInvitedView: UIView, ZMUserObserver {
        private var userObserverToken: NSObjectProtocol?
        
        fileprivate lazy var userIcon: UserImageViewForSecret = {
            let userImageView = UserImageViewForSecret()
            userImageView.userSession = ZMUserSession.shared()
            return userImageView
        }()
        
        fileprivate lazy var userName: UILabel = {
           let lab = UILabel()
            lab.textAlignment = .center
            lab.font = UIFont(15, .regular)
            lab.textColor = .dynamic(scheme: .title)
            return lab
        }()
        
        fileprivate lazy var titleLabel: UILabel = {
            let lab = UILabel()
            lab.textAlignment = .center
            lab.font = UIFont(13, .regular)
            lab.textColor = .dynamic(scheme: .note)
            return lab
        }()
        
        fileprivate lazy var subtitleLabel: UILabel = {
            let lab = UILabel()
            lab.numberOfLines = 0
            lab.textAlignment = .center
            lab.font = UIFont(14, .regular)
            lab.textColor = .dynamic(scheme: .note)
            return lab
        }()
        
        fileprivate lazy var confirmBtn: UIButton = {
            let btn = UIButton()
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = .dynamic(scheme: .brand)
            btn.layer.cornerRadius = 5
            return btn
        }()
        
        fileprivate var leftLine: UIView = {
            let line = UIView()
            line.backgroundColor = .dynamic(scheme: .separator)
            return line
        }()
        
        fileprivate var rightLine: UIView = {
            let line = UIView()
            line.backgroundColor = .dynamic(scheme: .separator)
            return line
        }()
        
        fileprivate var memberTitleLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont(13, .regular)
            label.textColor = .dynamic(scheme: .title)
            label.text = "conversation.groupinvite.member.title".localized
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            configureViews()
            createConstraints()
        }
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configUser(inviterId: String, reason: String, nums: Int, asset: String = "", isUserConfirm: Bool = false, conversationId: String? = nil) {
            if isUserConfirm {
                var placeholder = "groupIcon_slices"
                if let hash = conversationId?.hashValue {
                    placeholder = "group_avatar0" + "\(abs(hash) % 6 + 1)"
                }
                userIcon.setImage(urlString: asset, placeholder: placeholder)
                userName.text = inviterId
                
                titleLabel.font = UIFont(13, .regular)
                titleLabel.textColor = .dynamic(scheme: .note)
                
                self.subtitleLabel.isHidden = true
                
                NSLayoutConstraint.activate([
                    titleLabel.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 10),
                    titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -22)
                ])
            } else {
                titleLabel.font = UIFont(16, .regular)
                titleLabel.textColor = .dynamic(scheme: .title)
                titleLabel.text = "conversation.group_invite.vc.info.title".localized(args: nums)
                
                subtitleLabel.text = reason
                
                ZMUser.createUserIfNeededWithRemoteID(inviterId) {[weak self] (user) in
                    guard let self = self else { return }
                    self.userIcon.user = user
                    self.userName.text = user?.reMark ?? user?.newName() ?? ""
                    if let session = ZMUserSession.shared(), let user = user {
                        self.userObserverToken = UserChangeInfo.add(observer: self, for: user, userSession: session)
                    }
                }
                
                NSLayoutConstraint.activate([
                    titleLabel.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 40),
                    memberTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -22)
                ])
                
            }
        }
        
        func userDidChange(_ changeInfo: UserChangeInfo) {
            if let user = changeInfo.user as? ZMUser {
                self.userName.text = user.reMark ?? user.newName()
            }
        }
        
        private func configureViews() {
            backgroundColor = .dynamic(scheme: .cellBackground)
            [userIcon, userName, titleLabel, subtitleLabel, confirmBtn, leftLine, rightLine, memberTitleLabel].forEach(addSubview)
        }
        
        private func createConstraints() {
            [userIcon, userName, titleLabel, subtitleLabel, confirmBtn, leftLine, rightLine, memberTitleLabel].forEach { (view) in
                view.translatesAutoresizingMaskIntoConstraints = false
            }
            NSLayoutConstraint.activate([
                userIcon.topAnchor.constraint(equalTo: topAnchor, constant: 47),
                userIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
                userIcon.widthAnchor.constraint(equalToConstant: 60),
                userIcon.heightAnchor.constraint(equalToConstant: 60),
                
                userName.topAnchor.constraint(equalTo: userIcon.bottomAnchor, constant: 10),
                userName.centerXAnchor.constraint(equalTo: centerXAnchor),
                
                titleLabel.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 25),
                titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                
                subtitleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
                subtitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
                
                confirmBtn.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
                confirmBtn.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
                confirmBtn.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
                confirmBtn.heightAnchor.constraint(equalToConstant: 44),
                
                memberTitleLabel.topAnchor.constraint(equalTo: confirmBtn.bottomAnchor, constant: 22),
                memberTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                
                leftLine.centerYAnchor.constraint(equalTo: memberTitleLabel.centerYAnchor),
                leftLine.leftAnchor.constraint(equalTo: leftAnchor),
                leftLine.rightAnchor.constraint(equalTo: memberTitleLabel.leftAnchor, constant: -16),
                leftLine.heightAnchor.constraint(equalToConstant: CGFloat.hairline),

                rightLine.centerYAnchor.constraint(equalTo: memberTitleLabel.centerYAnchor),
                rightLine.leftAnchor.constraint(equalTo: memberTitleLabel.rightAnchor, constant: 16),
                rightLine.rightAnchor.constraint(equalTo: rightAnchor),
                rightLine.heightAnchor.constraint(equalToConstant: CGFloat.hairline)
            ])
        }
    }

    class GroupAddConfirmBtnsView: UIView {
       
        enum Status {
            case `default`
            case join
            case refuse
        }
        
        fileprivate lazy var invitedReason: UILabel = {
            let lab = UILabel()
            lab.numberOfLines = 0
            lab.textAlignment = .center
            lab.font = UIFont(17, .regular)
            lab.textColor = .dynamic(scheme: .title)
            return lab
        }()
        lazy var joinBtn: UIButton = {
            let btn = UIButton()
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = .dynamic(scheme: .brand)
            btn.layer.cornerRadius = 5
            return btn
        }()
        
        lazy var refuseBtn: UIButton = {
            let btn = UIButton()
            btn.setTitleColor(.dynamic(scheme: .brand), for: .normal)
            btn.layer.cornerRadius = 5
            btn.setTitle("conversation.groupinvite.confirm.refuse".localized, for: .normal)
            return btn
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            configureViews()
            createConstraints()
        }
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configTitle(title: String) {
            invitedReason.text = "\(title) \("conversation.groupinvite.add.other".localized)"
        }
        
        func configStatus(status: Status) {
            switch status {
            case .default:
                refuseBtn.isHidden = false
                joinBtn.setTitleColor(.white, for: .normal)
                joinBtn.backgroundColor = .dynamic(scheme: .brand)
                joinBtn.setTitle("conversation.groupinvite.confirm.join".localized, for: .normal)
                joinBtn.isEnabled = true
            case .join:
                refuseBtn.isHidden = true
                joinBtn.setTitleColor(.dynamic(scheme: .brand), for: .normal)
                joinBtn.backgroundColor = .dynamic(scheme: .separator)
                joinBtn.setTitle("conversation.groupinvite.confirm.joined".localized, for: .normal)
                joinBtn.isEnabled = false
            case .refuse:
                refuseBtn.isHidden = true
                joinBtn.setTitleColor(.dynamic(scheme: .brand), for: .normal)
                joinBtn.backgroundColor = .dynamic(scheme: .separator)
                joinBtn.setTitle("conversation.groupinvite.confirm.refused".localized, for: .normal)
                joinBtn.isEnabled = false
            }
        }
        
        private func configureViews() {
            self.backgroundColor = .dynamic(scheme: .cellBackground)
            [invitedReason, joinBtn, refuseBtn].forEach(addSubview)
            [invitedReason, joinBtn, refuseBtn].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
        }
        
        
        private func createConstraints() {
            NSLayoutConstraint.activate([
                invitedReason.topAnchor.constraint(equalTo: topAnchor, constant: 47),
                invitedReason.centerXAnchor.constraint(equalTo: centerXAnchor),
                
                joinBtn.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
                joinBtn.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
                joinBtn.topAnchor.constraint(equalTo: invitedReason.bottomAnchor, constant: 30),
                joinBtn.heightAnchor.constraint(equalToConstant: 44),
                
                refuseBtn.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
                refuseBtn.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
                refuseBtn.topAnchor.constraint(equalTo: joinBtn.bottomAnchor, constant: 20),
                refuseBtn.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
    }
    
    class GroupInviteCollectionViewlayout: UICollectionViewFlowLayout {
        
        var attrsArray: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
        
        
        override func prepare() {
            super.prepare()

            self.attrsArray.removeAll()
            let count: NSInteger = (collectionView?.numberOfItems(inSection: 0))!
            for i in 0..<count {
                let indexpath: NSIndexPath = NSIndexPath(item: i, section: 0)
                let atts: UICollectionViewLayoutAttributes = layoutAttributesForItem(at: indexpath as IndexPath)!
                attrsArray.append(atts)
            }

        }
    
        override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            var x: CGFloat = 0
            var y: CGFloat = 0
            let w: CGFloat = self.itemSize.width
            let h: CGFloat = self.itemSize.height
            let margin: CGFloat = 20
            
            let attr = super.layoutAttributesForItem(at: indexPath)
            y = margin + (h + margin) * CGFloat(indexPath.item / 5)
           
            if indexPath.item % 5 == 0 {
                x = CGFloat.screenWidth / 2 - (w / 2)
            } else if indexPath.item % 5 == 1 {
                x = CGFloat.screenWidth / 2 - (w / 2) - margin - w
            } else if indexPath.item % 5 == 2 {
                x = CGFloat.screenWidth / 2 + (w / 2) + margin
            } else if indexPath.item % 5 == 3 {
                x = CGFloat.screenWidth / 2 - (w / 2) - margin * 2 - w * 2
            } else {
                x = CGFloat.screenWidth / 2 + (w / 2) + margin * 2 + w
            }
            attr?.frame = CGRect (x: x, y: y, width: w, height: h)
            return attr
        }
        
        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            
            return attrsArray
        }
    }
    
}

extension GroupInvitedConfirmController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParticipantsListCellID", for: indexPath) as! GroupUrlShareCollectionCell
        cell.configUser(with: self.datasource[indexPath.item], conversation: self.conversation)
        return cell
    }
}
