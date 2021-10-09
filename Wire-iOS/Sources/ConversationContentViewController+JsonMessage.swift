//
//  ConversationContentViewController+JsonMessage.swift
//  Wire-iOS
//


import Foundation
import SwiftyJSON
import CoreLocation

extension ConversationContentViewController {
    
    @objc func clickJsonMessage(_ message: ZMConversationMessage) {

        view.window?.endEditing(true)
        guard let jsonMessageText = message.jsonTextMessageData?.jsonMessageText else { return }
        let object = ConversationJSONMessage(jsonMessageText)
        
        if object.type == .inviteGroupMemberVerify, let zmmessage = message as? ZMMessage {
            guard !(message.sender?.isSelfUser ?? true) else {return}
            guard let originStr = zmmessage.jsonTextMessageData?.jsonMessageText, !originStr.isEmpty else {
                HUD.text("conversation.alert.confirmAddContact.message_corrupted".localized)
                return
            }
            let dictionary = JSON(parseJSON: originStr)
            guard dictionary["msgData"].dictionary != nil else {
                HUD.text("conversation.alert.confirmAddContact.message_corrupted".localized)
                return
            }
            if let groupid = dictionary["msgData"]["conversationId"].string,
                let uuid = UUID(uuidString: groupid),
                let conversation = ZMConversation(remoteID: uuid) {
                if conversation.activeParticipants.contains(ZMUser.selfUser()) {
                    ZClientViewController.shared?.select(conversation: conversation, focusOnView: true, animated: true)
                    return
                } else {
                    zmmessage.isGet = false
                }
                
            }
            let confirmVC = GroupInvitedConfirmController(conversation: self.conversation, context: .userConfirm(zmmessage))
            self.parent?.present(confirmVC.wrapInNavigationController(), animated: true, completion: nil)
        } else if object.type == .confirmAddContact, let zmmessage = message as? ZMMessage {
            guard let originStr = zmmessage.jsonTextMessageData?.jsonMessageText, !originStr.isEmpty else {
                HUD.text("conversation.alert.confirmAddContact.message_corrupted".localized)
                return
            }
            let dictionary = JSON(parseJSON: originStr)
            guard dictionary["msgData"].dictionary != nil else {
                HUD.text("conversation.alert.confirmAddContact.message_corrupted".localized)
                return
            }
            let confirmVC = GroupInvitedConfirmController(conversation: self.conversation, context: .creatorConfirm(zmmessage))
            confirmVC.dismissListener = { [weak self] in
                self?.tableView.reloadData()
            }
            self.parent?.present(confirmVC.wrapInNavigationController(), animated: true, completion: nil)
        }
    }
    
    func didCompleteFormStep(_ viewController: UIViewController) {
        
    }
}
