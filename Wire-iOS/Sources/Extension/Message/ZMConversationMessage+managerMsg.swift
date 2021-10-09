


import Foundation

extension ZMConversationMessage {
    
    var managerMsg: String {
        var text: String = ""
        guard let `systemMessageData` = systemMessageData
            else { return text }
        if case .managerMsg = systemMessageData.systemMessageType {
            switch systemMessageData.managerType {
            case .meBecameManager:
                text = "conversation.status.you".localized + "conversation.setting.manager.systemMsg.became".localized
            case .otherBecameManager:
                text = (systemMessageData.text ?? "conversation.status.someone".localized) + "conversation.setting.manager.systemMsg.became".localized
            case .meDropManager:
                text = "conversation.status.you".localized + "conversation.setting.manager.systemMsg.drop".localized
            case .otherDropManager:
                text = (systemMessageData.text ?? "conversation.status.someone".localized) + "conversation.setting.manager.systemMsg.drop".localized
            @unknown default:
                fatalError()
            }
        }
        return text
    }
}
