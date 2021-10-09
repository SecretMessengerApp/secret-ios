//
//  GroupDetailsHeaderImgCell.swift
//  Wire-iOS
//

import UIKit

class GroupDetailsHeaderImgOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.headerimgoptions"
        title = "conversation.setting.to.group.icon".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        if let data = conversation.avatarData(size: .preview) {
            self.accessoryHeaderImg = UIImage(data: data)
        }
    }
    
}
