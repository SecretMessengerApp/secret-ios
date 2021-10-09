//
//  GroupDetailsSilenceOptionsCell.swift
//  Wire-iOS
//

import UIKit

class GroupDetailsSilenceOptionsCell: GroupDetailsOptionsCell {
    
    var conversation: ZMConversation?
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.silenceoptions"
        title = "meta.menu.silence.mute".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        self.accessorySwitch = conversation.mutedMessageTypes != .none
    }
    
    override func switchChange(value: UISwitch) {
        self.conversation?.mutedMessageTypes = value.isOn ? .regular : .none
    }
}

class GroupDetailsDoNotDisturbGroupOptionsCell: GroupDetailsOptionsCell {
    
    var conversation: ZMConversation?
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.DoNotDisturbGroup"
        title = "meta.menu.do_not_disturb_group".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        self.accessorySwitch = conversation.isNotDisturb
        self.enableSwitch = !conversation.isPlacedTop
    }
    
    override func switchChange(value: UISwitch) {
        self.conversation?.isNotDisturb = value.isOn
        if value.isOn {
            conversation?.mutedMessageTypes = .regular
        }
    }
}

class GroupManageCreatorInviteOptionsCell: GroupDetailsOptionsCell {
    
    var conversation: ZMConversation?
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.CreatorInvite"
        title = "conversation.setting.to.group.ownerInvite".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        self.accessorySwitch = conversation.isOnlyCreatorInvite
    }
    
    override func switchChange(value: UISwitch) {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation?.isOnlyCreatorInvite = value.isOn
            if value.isOn, self.conversation?.isOpenUrlJoin ?? false {
                self.conversation?.isOpenUrlJoin = false
            }
        }
    }
}

class GroupManageOpenLinkJoinOptionsCell: GroupDetailsOptionsCell {
    
    var conversation: ZMConversation?
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.OpenLinkJoin"
        title = "conversation.setting.to.openjoin.url".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        self.accessorySwitch = conversation.isOpenUrlJoin
        if conversation.isOpenCreatorInviteVerify || conversation.isOnlyCreatorInvite {
            self.enableSwitch = false
        } else {
            self.enableSwitch = true
        }
    }
    
    override func switchChange(value: UISwitch) {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation?.isOpenUrlJoin = value.isOn
        }
    }
}

class GroupManageAllowViewMembersOptionsCell: GroupDetailsOptionsCell {
    
    var conversation: ZMConversation?
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.AllowViewMembers"
        title = "conversation.setting.to.group.allowViewMembers".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        self.accessorySwitch = conversation.isAllowViewMembers
    }
    
    override func switchChange(value: UISwitch) {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation?.isAllowViewMembers = value.isOn
        }
    }
}

class GroupManageMemberConfirmOptionsCell: GroupDetailsOptionsCell {
    
    var conversation: ZMConversation?
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.MemberConfirm"
        title = "conversation.setting.to.group.MemberConfirm".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        self.accessorySwitch = conversation.isOpenMemberInviteVerify
        if conversation.isOpenCreatorInviteVerify {
            self.enableSwitch = false
        } else {
            self.enableSwitch = true
        }
    }
    
    override func switchChange(value: UISwitch) {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation?.isOpenMemberInviteVerify = value.isOn
        }
    }
}

class GroupManageMessageVisibleOptionsCell: GroupDetailsOptionsCell {
    
    var conversation: ZMConversation?
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.message.visible"
        title = "conversation.setting.to.message.visible.only.manager.creator".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        self.accessorySwitch = conversation.isMessageVisibleOnlyManagerAndCreator
    }
    
    override func switchChange(value: UISwitch) {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation?.isMessageVisibleOnlyManagerAndCreator = value.isOn
        }
    }
}

class GroupManageShowMemsumOptionsCell: GroupDetailsOptionsCell {
    
    var conversation: ZMConversation?

    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.ShowMemsum"
        title = "conversation.setting.to.showMemsum".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        self.accessorySwitch = conversation.showMemsum
    }
    
    override func switchChange(value: UISwitch) {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation?.showMemsum = value.isOn
        }
    }
}

class GroupManageEnabledEditMsgOptionsCell: GroupDetailsOptionsCell {
    
    var conversation: ZMConversation?
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.EnabledEditMsg"
        title = "conversation.setting.to.enableEditMsg".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        self.accessorySwitch = conversation.enabledEditMsg
    }
    
    override func switchChange(value: UISwitch) {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation?.enabledEditMsg = value.isOn
        }
    }
}
