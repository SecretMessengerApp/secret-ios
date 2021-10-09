

import UIKit

extension ZMConversationMessage {
    var allowViewmen: String {
        var title = ""
        guard let `systemMessageData` = systemMessageData else {return title}
        guard case .allowViewmen = systemMessageData.systemMessageType else {return title}
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
        
        if systemMessageData.viewmem == "0" {
            title = "\(senderDisplayName)" + "message.disable.allowViewMembers.close".localized
        } else {
            title = "\(senderDisplayName)" + "message.disable.allowViewMembers.open".localized
        }
        return title
    }
}
