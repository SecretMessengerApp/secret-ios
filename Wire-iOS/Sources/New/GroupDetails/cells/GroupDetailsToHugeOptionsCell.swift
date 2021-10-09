//
//  GroupDetailsToHugeCell.swift
//  Wire-iOS
//
import UIKit

class GroupDetailsToHugeOptionsCell: GroupDetailsOptionsCell {

    private var conversation: ZMConversation?

    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.tohugeoptions"
        title = "conversation.setting.to.huge.conversation".localized
        status = "conversation.setting.to.upgrade.over.100".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        if conversation.conversationType == .hugeGroup {
            title = "conversation.setting.to.upgraded.huge.conversation".localized
            status = nil
            switchIsHidden = true
        } else {
            accessorySwitch = false
            enableSwitch = conversation.creator.isSelfUser && conversation.activeParticipants.count >= 100
        }
    }
    
    override func switchChange(value: UISwitch) {
        guard let conversation = conversation,
            let cid = conversation.remoteIdentifier?.transportString() else { return }
        ConversationBGPService.toBGP(conversationId: cid) { [weak self] result in
            switch result {
            case .success:
                HUD.success("conversation.setting.to.upgraded.huge.conversation".localized)
                ZMUserSession.shared()?.enqueueChanges {
                    conversation.conversationType = .hugeGroup
                }
            case .failure(let msg):
                self?.accessorySwitch = false
                HUD.error(msg)
            }
        }
    }
}


class GroupDetailsDisableSendMsgOptionsCell: GroupDetailsOptionsCell {
    private var conversation: ZMConversation?
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.disablesendmsg"
        title = "conversation.setting.to.group.disablesendmsg".localized
        status = "conversation.setting.to.group.disablesendmsg.status".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        accessorySwitch = conversation.isDisableSendMsg
    }
    
    override func switchChange(value: UISwitch) {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation?.isDisableSendMsg = value.isOn
        }
    }
}


class GroupManageInviteConfirmOptionsCell: GroupDetailsOptionsCell {
    
    fileprivate var conversation:ZMConversation?
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.inviteconfirm"
        title = "conversation.setting.to.group.confirmTitle".localized
        status = "conversation.setting.to.group.confirmSubtitle".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        self.accessorySwitch = conversation.isOpenCreatorInviteVerify
    }
    
    override func switchChange(value: UISwitch) {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation?.isOpenCreatorInviteVerify = value.isOn
            if value.isOn {
                if self.conversation?.isOpenUrlJoin ?? false {
                     self.conversation?.isOpenUrlJoin = false
                }
                if self.conversation?.isOpenMemberInviteVerify ?? false {
                    self.conversation?.isOpenMemberInviteVerify = false
                }
            }
            
        }
    }

}

class GroupManageScreenShotOptionsCell: GroupDetailsOptionsCell {
    
    fileprivate var conversation: ZMConversation?
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.screenshot"
        title = "conversation.setting.screenShot".localized
        status = "conversation.setting.screenShot.detail".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        self.conversation = conversation
        self.accessorySwitch = conversation.isOpenScreenShot
    }
    
    override func switchChange(value: UISwitch) {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation?.isOpenScreenShot = value.isOn            
        }
    }
}
