

import Foundation

extension ZMConversationMessage {
    
    var disableStatus: String {
        var title = ""
        var currentUserName: String = ""
        var opt_name: String = ""
        guard let `systemMessageData` = systemMessageData else {return title}
        if let userid = systemMessageData.blockUser, let uuid = UUID.init(uuidString: userid) {
            currentUserName = ZMUser.init(remoteID: uuid, createIfNeeded: false, in: ZMUserSession.shared()?.managedObjectContext)?.displayName(in: conversation) ?? ""
        }
        if let opt_id = systemMessageData.opt_id, let uuid = UUID.init(uuidString: opt_id) {
            opt_name = ZMUser.init(remoteID: uuid, createIfNeeded: false, in: ZMUserSession.shared()?.managedObjectContext)?.displayName(in: conversation) ?? ""
        }
        guard let senderID = sender?.remoteIdentifier.transportString() else { return title}
        let isManager = conversation?.manager?.contains(senderID) ?? false
        switch (systemMessageData.systemMessageType, systemMessageData.blockTime?.int64Value, sender?.isSelfUser, isManager, systemMessageData.blockDuration?.int64Value) {
        case (.allDisableSendMsg, 0, true, _, _):
            title = "message.disable.you".localized + "message.disable.all.close".localized
        case (.allDisableSendMsg, 0, false, _, _):
            title = "message.disable.creator".localized + " " + opt_name + " " + "message.disable.all.close".localized
        case (.allDisableSendMsg, -1, true, _, _):
            title = "message.disable.you".localized + "message.disable.all.open".localized
        case (.allDisableSendMsg, -1, false, _, _):
            title = "message.disable.creator".localized + " " + opt_name + " " + "message.disable.all.open".localized
        case (.memberDisableSendMsg, 0, true, _, _):
            title = currentUserName + " " + "message.disable.passivity".localized + "message.disable.you".localized + "message.disable.relieve".localized + "message.disable".localized
        case (.memberDisableSendMsg, -1, true, _, _):
            title = currentUserName + " " + "message.disable.passivity".localized + "message.disable.you".localized + "message.disable".localized
        case (.memberDisableSendMsg, 0, false, true, _):
            title = "message.disable.you".localized + "message.disable.passivity".localized + "message.disable.manager".localized + "message.disable.relieve".localized + "message.disable".localized
        case (.memberDisableSendMsg, 0, false, false, _):
            title = "message.disable.you".localized + "message.disable.passivity".localized + "message.disable.creator".localized + "message.disable.relieve".localized + "message.disable".localized
        case (.memberDisableSendMsg, -1, false, true, _):
            title = "message.disable.you".localized + "message.disable.passivity".localized + "message.disable.manager".localized + "message.disable.relieve".localized + "message.disable".localized
        case (.memberDisableSendMsg, -1, false, false, _):
            title = "message.disable.you".localized + "message.disable.passivity".localized + "message.disable.creator".localized + "message.disable".localized
            
        case (.memberDisableSendMsg, _, true, _, let blockDurationTime):
            if let block = blockDurationTime {
                title = currentUserName + " " + "message.disable.passivity".localized + "message.disable.you".localized + "message.disable".localized + " " + block.displayString
            }
        case (.memberDisableSendMsg, _, false, true, let blockDurationTime):
            if let block = blockDurationTime {
                title = "message.disable.you".localized + "message.disable.passivity".localized + "message.disable.manager".localized + "message.disable".localized + " " + block.displayString
            }
        case (.memberDisableSendMsg, _, false, false, let blockDurationTime):
            if let block = blockDurationTime {
                title = "message.disable.you".localized + "message.disable.passivity".localized + "message.disable.creator".localized + "message.disable".localized + " " + block.displayString
            }
            
        default:
            title = ""
        }
        return title
    }
    
}
