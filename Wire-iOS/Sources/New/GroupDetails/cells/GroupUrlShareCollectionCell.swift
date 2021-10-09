//
//  GroupUrlShareCollectionCell.swift
//  Wire-iOS
//

import UIKit

class GroupUrlShareCollectionCell: UICollectionViewCell, ZMUserObserver {
    
    private let iconView = BadgeUserImageView()
    private let labelView = UILabel()
    private var userObserverToken: NSObjectProtocol?
    private var user: UserType?
    private var conversation: ZMConversation?
    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            iconView.badgeIcon = isSelected ? StyleKitIcon.checkmark : nil
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUser(with user: UserType, conversation: ZMConversation?) {
        self.user = user
        self.conversation = conversation
        iconView.userSession = ZMUserSession.shared()
        iconView.user = user
        if let session = ZMUserSession.shared() {
            userObserverToken = UserChangeInfo.add(observer: self, for: user, userSession: session)
        }
        
        labelView.text = user.displayName(in: conversation)
    }
    
    private func setupViews() {
        iconView.isEnabled = false
        labelView.textColor = .dynamic(scheme: .title)
        labelView.font = UIFont(11, .regular)
        labelView.textAlignment = .center
        let views = [iconView, labelView]
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        views.forEach(contentView.addSubview)
    }
    
    private func createConstraints() {
        NSLayoutConstraint.activate(
            [
                iconView.topAnchor.constraint(equalTo: contentView.topAnchor),
                iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                iconView.heightAnchor.constraint(equalToConstant: 46),
                iconView.widthAnchor.constraint(equalToConstant: 46)
            ] + [
                labelView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                labelView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                labelView.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8),
                labelView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
            ]
        )
    }
    
    func userDidChange(_ changeInfo: UserChangeInfo) {
        if let conversation = self.conversation {
            labelView.text = changeInfo.user.displayName(in: conversation)
        }
    }
    
}
