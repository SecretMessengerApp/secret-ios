
import Foundation
import SwiftyJSON

extension ZMConversation {
    //url
    //name
    //zipId
    //zipName
    //zipIcon 
    func appendExpressionMessage(url: String, name: String?, zipId: String?, zipName: String?, zipIcon: String?) {
        let msg = ConversationJSONMessage.ExpressionPayload(url: url, name: name, zipId: zipId, zipName: zipName, zipIcon: zipIcon).build()
        LocalExpressionStore.recent.addData(url)
        ExpressionModel.shared.postRecentExpressionChanged()
        ZMUserSession.shared()?.enqueueChanges ({
            self.append(jsonText: msg)
            WRTools.playSendMessageSound()
        }, completionHandler: nil)
    }
}

extension ConversationJSONMessage {
    
    
    
    struct Expression {
        
        let url: String
        let name: String?
        let zipId: String?
        let zipName: String?
        let zipIcon: String?
        
        init(json: JSON) {
            self.url = json["url"].stringValue
            self.name = json["name"].string
            self.zipId = json["zipId"].string
            self.zipName = json["zipName"].string
            self.zipIcon = json["zipIcon"].string
        }
        
    }
    
    struct ExpressionPayload {
        
        let url: String
        let name: String?
        let zipId: String?
        let zipName: String?
        let zipIcon: String?
        
        
        func build() -> String {
            var msgData: [String: Any] = [
                "url": url
            ]
            
            if let n = name {
                msgData["name"] = n
            }
            
            if let zid = zipId {
                msgData["zipId"] = zid
            }
            
            if let zname = zipName {
                msgData["zipName"] = zname
            }
            
            if let zicon = zipIcon {
                msgData["zipIcon"] = zicon
            }
            
            var params: [String: Any] = [
                "msgData": msgData
            ]

            params["msgType"] = "21"
            guard let msg = JSON(params).rawString() else {
                fatalError("JSON format error")
            }
            return msg
        }
        
    }
    
    
    
}
