

import Foundation

extension ZMConversationMessage {
    
    var allowAddFriendsStatus: String {
        var title = ""
        guard let `systemMessageData` = systemMessageData else {return title}
        guard case .allowAddFriend = systemMessageData.systemMessageType else {return title}
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
        if systemMessageData.add_friend == "0" {
            title = "\(senderDisplayName)" + "message.disable.addfriend.open".localized
        } else {
            title = "\(senderDisplayName)" + "message.disable.addfriend.close".localized
        }
        return title
    }
}
