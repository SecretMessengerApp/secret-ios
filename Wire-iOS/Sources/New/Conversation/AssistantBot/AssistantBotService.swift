

import Foundation
import SwiftyJSON

class AssistantBotService: NetworkRequest {
    
    static func sendAssistantBotMessage(content: String, cid: String, completion: @escaping (BaseResult<String, String>) -> Void) {
        let operation = "RequestChat"
        let platform = "SecretGroupAssistant"
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let url = API.Base.backend + API.Conversation.conversations + "/" + cid + API.Conversation.bot
        let params = ["operation": operation,
                      "platform": platform,
                      "timestamp": "\(timestamp)",
                      "content": content]
        request(url, method: .post, parameters: params, encoding: .json(.default) ).responseDataErrorBeLocalized { (response) in
            switch response.result {
            case .failure(let err): completion(.failure(err.localizedDescription))
            case .success(let value):
                let resultString = JSON(value)["text"].stringValue
                completion(.success(resultString))
            }
        }
        
    }
    
}
