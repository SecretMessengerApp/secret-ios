

import Foundation

extension ZMConversation {
    
    func appendAssistantBotMessage(content: String) {
        guard let botid = self.assistantBot else {return}
        let bot = ConversationJSONMessage.AssistantBot(content: content, fromUserId: botid)
        ZMUserSession.shared()?.enqueueChanges {
            self.append(jsonText: bot.build())
        }
    }
    
}
