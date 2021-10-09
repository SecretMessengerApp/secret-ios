//
//  ConversationContentViewController+ChangeBG.swift
//  Wire-iOS
//

import Foundation

extension ConversationContentViewController {

    func reloadBackgroundImage() {
        let imageName = WBConvnBGImageStorager.sharedInstance.imageName(conversationId: self.conversation.remoteIdentifier?.uuidString ?? "")
        let backView = UIImageView(image: UIImage(named: imageName))
        backView.transform = CGAffineTransform(rotationAngle: .pi).scaledBy(x: -1, y: 1)
        backView.contentMode = .scaleAspectFill
        backView.applyMotion()
        
        let container = UIView()
        self.tableView.backgroundView = container
        
        let amount: CGFloat = 20
        
        container.addSubview(backView)
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: -amount).isActive = true
        backView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: amount).isActive = true
        backView.topAnchor.constraint(equalTo: container.topAnchor, constant: -amount).isActive = true
        backView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: amount).isActive = true
    }

    @objc func conversationBackgroundImageChanged(_ notification: Notification) {
        let info = notification.userInfo
        let conId = info?["conversationId"] as? String
        let currentId = dataSource.conversation.remoteIdentifier?.uuidString
        if conId == currentId {
            reloadBackgroundImage()
        }
    }
}
