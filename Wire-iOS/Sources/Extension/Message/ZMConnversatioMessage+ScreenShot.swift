

import Foundation

extension ZMConversationMessage {
    
    var screenShotStatus: String {
        var title = ""
        guard let `systemMessageData` = systemMessageData else {return title}
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
        if case .screenShotClosed = systemMessageData.systemMessageType {
            title = "\(senderDisplayName)" + "message.disable.screenshot.close".localized
        } else if case .screenShotOpened = systemMessageData.systemMessageType {
            title = "\(senderDisplayName)" + "message.disable.screenshot.open".localized
        }
        return title
    }
}
