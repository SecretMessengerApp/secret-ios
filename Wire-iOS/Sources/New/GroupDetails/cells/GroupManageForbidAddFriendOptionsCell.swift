//
//  GroupManageForbidAddFriendOptionsCell.swift
//  Wire-iOS
//

import UIKit

class GroupManageForbidAddFriendOptionsCell: GroupDetailsOptionsCell {
    
    fileprivate var conversation: ZMConversation!
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.forbid_add_friend".localized
        title = "conversation.setting.to.group.forbid_add_friend".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        self.accessorySwitch = !conversation.isAllowMemberAddEachOther
    }
    
    override func switchChange(value: UISwitch) {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation.isAllowMemberAddEachOther = !value.isOn
        }
    }
    
}
