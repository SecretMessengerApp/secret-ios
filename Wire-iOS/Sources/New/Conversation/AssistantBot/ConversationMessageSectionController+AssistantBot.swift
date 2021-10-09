

import Foundation

extension ConversationMessageSectionController {
    
     func doAssistantBot(_ changeInfo: MessageChangeInfo) {
        
        let message = changeInfo.message
        let deliveryState = message.deliveryState
        
        if changeInfo.deliveryStateChanged
            && (deliveryState == .delivered ||  deliveryState == .sent),
            let conversation = message.conversation,
            conversation.conversationType == .hugeGroup
        {
            let message = changeInfo.message
            if message.isNeedAssistantBotReply {
                ZMUserSession.shared()?.performChanges {
                    message.isNeedAssistantBotReply = false
                }
                guard let text = message.textMessageData?.messageText else {return}
                guard let cid = message.conversation?.remoteIdentifier?.transportString() else {return}
                AssistantBotService.sendAssistantBotMessage(content: text, cid: cid) { (result) in
                    switch result {
                    case .success(let content):
                        message.conversation?.appendAssistantBotMessage(content: content)
                    default:
                        break
                    }
                }
            }
        }
     }
}
