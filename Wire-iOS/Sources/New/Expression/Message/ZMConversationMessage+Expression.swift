
import Foundation

extension ZMConversationMessage {
    
    var canBeAdded: Bool {
        if let jsonMessageText = jsonTextMessageData?.jsonMessageText {
            let jsonMessage = ConversationJSONMessage(jsonMessageText)
            if jsonMessage.type == .expression {
                return true
            }
        }
        if self.imageMessageData?.isAnimatedGIF ?? false {
            return true
        }
        return false
    }
    
    var expressionUrl: String? {
        if let jsonMessageText = jsonTextMessageData?.jsonMessageText {
            let jsonMessage = ConversationJSONMessage(jsonMessageText)
            if jsonMessage.type == .expression {
                return jsonMessage.expression?.url
            }
        }
        return nil
    }
    
}
