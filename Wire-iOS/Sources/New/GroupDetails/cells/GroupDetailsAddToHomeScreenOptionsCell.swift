//
//  GroupDetailsShortcutOptionsCell.swift
//  Wire-iOS
//

import UIKit

class GroupDetailsAddToHomeScreenOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "conversation.setting.to.group.add_to_home_screen"
        title = "conversation.setting.to.group.add_to_home_screen".localized
    }
}
