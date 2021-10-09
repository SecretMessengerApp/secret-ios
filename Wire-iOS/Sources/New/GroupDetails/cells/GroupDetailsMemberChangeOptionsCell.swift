//
//  GroupDetailsVisibleForMemberChangeOptionsCell.swift
//  Wire-iOS
//

import UIKit

class GroupDetailsMemberChangeOptionsCell: GroupDetailsOptionsCell {
    
    fileprivate var conversation: ZMConversation!
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails..member_change_unvisible".localized
        title = "conversation.setting.to.group.member_change_unvisible".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        self.accessorySwitch = !conversation.isVisibleForMemberChange
    }
    
    override func switchChange(value: UISwitch) {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation.isVisibleForMemberChange = !value.isOn
        }
    }
    
}
