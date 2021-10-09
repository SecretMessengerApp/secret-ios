//
//  GroupDetailsInviteUrlCell.swift
//  Wire-iOS
//

import UIKit

class GroupDetailsInviteUrlOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.inviteurloptions"
    }
    
    override func configure(with conversation: ZMConversation) {
        title = conversation.joinGroupUrl
    }
    
}
