

import UIKit

extension ZMConversationMessage {
    var enabledEditMsg: String {
        var title = ""
        guard let `systemMessageData` = systemMessageData else {return title}
        guard case .enabledEditMsg = systemMessageData.systemMessageType else {return title}
        var senderDisplayName: String
        if sender?.isSelfUser ?? false {
            senderDisplayName = "message.disable.you".localized
        } else {
            if sender?.remoteIdentifier == conversation?.creator.remoteIdentifier {
                senderDisplayName = "message.disable.creator".localized
            } else {
                senderDisplayName = sender?.displayName(in: conversation) ?? ""
            }
        }
        
        if systemMessageData.enabledEditMsg == "0" {
            title = "\(senderDisplayName)" + "message.disable.enableEditMsg.close".localized
        } else {
            title = "\(senderDisplayName)" + "message.disable.enableEditMsg.open".localized
        }
        return title
    }
}
