

import Foundation

extension ZMConversationMessage {
    
    var messageVisibleStatus: String {
        var title = ""
        guard let `systemMessageData` = systemMessageData else {return title}
        guard case .messageVisible = systemMessageData.systemMessageType else {return title}
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
        if systemMessageData.messageVisible == "1" {
            title = "\(senderDisplayName)" + "message.disable.messageVisible.open".localized
        } else {
            title = "\(senderDisplayName)" + "message.disable.messageVisible.close".localized
        }
        return title
    }
}
