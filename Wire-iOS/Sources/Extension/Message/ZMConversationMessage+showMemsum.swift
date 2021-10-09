

import UIKit

extension ZMConversationMessage {
    var showMemsum: String {
        var title = ""
        guard let `systemMessageData` = systemMessageData else {return title}
        guard case .showMemsum = systemMessageData.systemMessageType else {return title}
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
        
        if systemMessageData.showMemsum == "0" {
            title = "\(senderDisplayName)" + "message.disable.showMemsum.close".localized
        } else {
            title = "\(senderDisplayName)" + "message.disable.showMemsum.open".localized
        }
        return title
    }
}
