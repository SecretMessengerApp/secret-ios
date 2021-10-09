//
//  GroupDetailsPlaceTopOptionsCell.swift
//  Wire-iOS
//

import UIKit

class GroupDetailsPlaceTopOptionsCell: GroupDetailsOptionsCell {
    var conversation: ZMConversation?
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.place_top".localized
        title = "conversation.setting.place_top".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        self.accessorySwitch = conversation.isPlacedTop
        self.enableSwitch = !conversation.isNotDisturb
    }
    
    override func switchChange(value: UISwitch) {
        self.conversation?.isPlacedTop = value.isOn
    }
}
