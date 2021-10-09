//
//  GroupDetailsAliasNameCell.swift
//  Wire-iOS
//

import UIKit

class GroupDetailsAliasNameOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.aliasnameoptions"
        self.accessoryTextField.accessibilityIdentifier = GroupOptionsSectionController.aliasnameTextFieldAccessibilityIdentifier
        title = "conversation.group.nickName".localized.capitalized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.accessoryTextFieldString = conversation.selfRemark ?? ""
    }
    
}
