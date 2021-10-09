

import Foundation
import SwiftyJSON

extension ConversationJSONMessage {
    
    struct AssistantBot {
        var content: String
        var fromUserId: String
        
        func build() -> String {
            let params: [String: Any] = [
                "msgType": "23",
                "msgData": ["content": content, "fromUserId": fromUserId]
            ]
            guard let msg = JSON(params).rawString() else {
                fatalError("JSON format error")
            }
            return msg
        }
        
        init(content: String, fromUserId: String) {
            self.content = content
            self.fromUserId = fromUserId
        }
        
        init?(msgData: JSON) {
            content = msgData["content"].stringValue
            fromUserId = msgData["fromUserId"].stringValue
        }
    }
}
