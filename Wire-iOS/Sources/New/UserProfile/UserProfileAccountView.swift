//
//  UserProfileAccountView.swift
//  Wire-iOS
//

import UIKit
import Cartography

class UserProfileAccountView: UIView {
    var userObserverToken: NSObjectProtocol?
    var user: ZMUser
    var clickListener:(() -> Void)?

    public func setClickListener(listener:(() -> Void)?) {
        self.clickListener = listener
    }

    init(user: ZMUser) {
        self.user = user
        super.init(frame: .zero)
        userObserverToken = UserChangeInfo.add(userObserver: self, for: user, userSession: ZMUserSession.shared()!)
        self.addSubview(userImageView)
        self.addSubview(nameLabel)
        self.addSubview(handerLabel)
        self.createConstraints()
        configure()
    }

    func createConstraints() {
        constrain(self, userImageView, nameLabel, handerLabel) { (view, userimageview, namelabel, handerlabel) in
            userimageview.left == view.left + 24
            userimageview.centerY == view.centerY - 5
            userimageview.width == 51
            userimageview.height == 51
            namelabel.left == userimageview.right + 16
            namelabel.centerY == view.centerY - 13
            handerlabel.left == namelabel.left
            handerlabel.centerY == view.centerY + 13
        }
    }
    
    func configure() {
        userImageView.user = user
        handerLabel.text = "@\(user.handle ?? "")"
        if let remark = user.reMark {
            nameLabel.text = remark + " (" + (user.name ?? "") + ")"
        } else {
            nameLabel.text = user.newName()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate lazy var userImageView: UserImageViewForSecret = {
        let imageView = UserImageViewForSecret()
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        imageView.user = self.user
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(16, .regular)
        label.textColor = UIColor.dynamic(scheme: .title)
        label.text = user.newName()
        return label
    }()
    
    fileprivate lazy var handerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(13, .regular)
        label.textColor = UIColor.dynamic(scheme: .subtitle)
        label.text = "@\(self.user.handle ?? "")"
        return label
    }()
}

extension UserProfileAccountView: ZMUserObserver {
    public func userDidChange(_ note: UserChangeInfo) {
        configure()
    }
}
