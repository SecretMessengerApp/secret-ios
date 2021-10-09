

import UIKit

extension ConversationInputBarViewController {

    func createDisableSendMsgLabel() {
        disableSendMsgLabel.text = "conversation.setting.disableSendMsg.status.ing".localized
        disableSendMsgLabel.isUserInteractionEnabled = true
        disableSendMsgLabel.backgroundColor = .dynamic(scheme: .barBackground)
        disableSendMsgLabel.textAlignment = .center
        disableSendMsgLabel.font = .normalRegularFont
        view.addSubview(disableSendMsgLabel)
        
        disableSendMsgLabel.isHidden = true
        setDisableSendMsgStatus()
    }
    
    private func setUserDisableSendMsg() -> Bool {
        guard
            let moc = conversation.managedObjectContext,
            let selfUser = ZMUser.selfUser(),
            let cid = conversation.remoteIdentifier?.transportString()
            else { return false }
        
        let blockTime = UserDisableSendMsgStatus.getBlockTime(
            managedObjectContext: moc,
            user: selfUser.remoteIdentifier.transportString(),
            conversation: cid
        )
        
        guard let blockTimeStamp = blockTime?.intValue else { return false }
        
        if blockTimeStamp == 0 {
            disableSendMsgLabel.text = "conversation.setting.disableSendMsg.status.ing".localized
            disableSendMsgLabel.isHidden = true
            return false
        } else if blockTimeStamp == -1 {
            disableSendMsgLabel.text = "conversation.setting.disableSendMsg.status.ing".localized
            disableSendMsgLabel.isHidden = false
            return true
        } else {
            let total = blockTimeStamp - Int(Date().timeIntervalSince1970)
            disableSendMsgLabel.text = String(
                format: "%@(%@%02ldh%02ldm)",
                "conversation.setting.disableSendMsg.status.ing".localized, "conversation.setting.disableSendMsg.time.left".localized, total / 3600, (total / 60) % 60
            )
            disableSendMsgLabel.isHidden = false
            return true
        }
    }
    
    func setDisableSendMsgStatus() {
        
        let disableSendMsg = { [weak self] in
            self?.disableSendMsgLabel.isHidden = false
        }
        
        let openSendMsg = { [weak self] in
            self?.disableSendMsgLabel.isHidden = true
        }
        
        if conversation.remoteIdentifier?.transportString() == "11111111-0000-0000-0000-000000000002" {
            disableSendMsg()
            return
        }
        
       
        if conversation.creator.isSelfUser {
            openSendMsg()
            return
        }
        
       
        if setUserDisableSendMsg() {
            return
        }
        
        
        if let selfUser = ZMUser.selfUser() {
            let selfId = selfUser.remoteIdentifier.transportString()
            if let manager = conversation.manager, manager.contains(selfId) {
                openSendMsg()
                return
            }
            if let orator = conversation.orator, orator.contains(selfId) {
                openSendMsg()
                return
            }
        }
        
        disableSendMsgLabel.text = "conversation.setting.disableSendMsg.status.ing".localized
        disableSendMsgLabel.isHidden = !conversation.isDisableSendMsg
    }
}
