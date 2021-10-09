//
//  GroupDetailsShortcutOptionsCell.swift
//  Wire-iOS
//

import UIKit

class GroupDetailsShortcutOptionsCell: GroupDetailsOptionsCell {
    
    var conversation: ZMConversation?
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.shortcut.options"
        title = "conversation.setting.to.group.shortcut".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        self.accessorySwitch = Settings.shared.containsShortcutConversation(conversation) ?? false
    }
    
    override func switchChange(value: UISwitch) {
        guard let account = SessionManager.shared?.accountManager.selectedAccount,
              let conversation = self.conversation
            else { return }
        if case .hugeGroup = conversation.conversationType, conversation.isSelfAnActiveMember == false {
            ZMUserSession.shared()?.enqueueChanges {
                conversation.isSelfAnActiveMember = true
                conversation.isArchived = false
            }
        }
        if value.isOn {
            let success = Settings.shared.setShortcutConversation(conversation, for: account) ?? false
            if !success {
                value.isOn = false
            }
        } else {
            Settings.shared.removeShortcurConversation(conversation, for: account)
        }
        ZClientViewController.shared?.mainTabBarController?.setShortcutTabBarItem()
    }
}
