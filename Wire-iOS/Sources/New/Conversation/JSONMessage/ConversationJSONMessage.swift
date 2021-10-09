//
//  JSONMessage.swift
//  Wire-iOS

import Foundation
import SwiftyJSON

struct ConversationJSONMessage {
    /**
     Conversation-JSON
     */
    enum `Type`: String {
        case confirmLinkAddContact = "10"
        case confirmAddContact = "11"
        case inviteGroupMemberVerify = "12"
        case expression = "21"
        case screenShot = "24"
        case unknown
    }

    init(_ object: Any) {
        switch object {
        case let object as Data: self.object = try? JSON(data: object)
        case let object as String: self.object = JSON(parseJSON: object)
        default: self.object = JSON(object)
        }
    }

    private var object: JSON?

    var string: String? {
        return object?.rawString()
    }

    var dictionary: [String: Any]? {
        return object?.dictionaryObject
    }
    
    var dataDictionary: [String: Any]? {
        return object?["msgData"].dictionaryObject
    }

    var type: Type {
        guard let object = object else { return .unknown }
        guard let msgType = object["msgType"].string else { return .unknown }
        return Type(rawValue: msgType) ?? .unknown
    }
    
    var newClientInfo: NewClientInfo? {
        guard let obj = object else { return nil }
        return NewClientInfo(msgData: obj["msgData"])
    }
    
    var authLoginInfo: AuthLoginInfo? {
        guard let obj = object else { return nil }
        return AuthLoginInfo(msgData: obj["msgData"])
    }
    
    var expression: Expression? {
        guard let obj = object else { return nil }
        return Expression(json: obj["msgData"])
    }
    
    var assistantBot: AssistantBot? {
        guard let obj = object else { return nil }
        return AssistantBot(msgData: obj["msgData"])
    }
    
    var screenShotMessage: ScreenShot? {
        guard let obj = object else { return nil }
        return ScreenShot(msgData: obj["msgData"])
    }
    
}

extension ConversationJSONMessage {
    var getObject: JSON? {
        return object
    }
}

// MARK: - 
extension ConversationJSONMessage {

    struct NewClientInfo {
        let title = "conversation.system.client.login.title".localized
        let tips = "conversation.system.client.remove.no.know".localized
        let actionTitle = "conversation.system.goto.client.manager".localized
        var time: String?,
        model: String?
        init?(msgData: JSON) {
            time = msgData["time"].string
            model = msgData["model"].string
        }
    }
    
    struct AuthLoginInfo {
        let title = "conversation.system.auth.title".localized
        let tips = "conversation.system.client.remove.no.know".localized
        let actionTitle = "conversation.system.goto.client.manager".localized
        var time: String?,
        name: String?
        
        init?(msgData: JSON) {
            time = msgData["time"].string
            name = msgData["name"].string
        }
    }
    
}

// MARK: -
extension ConversationJSONMessage {
    
    struct ScreenShot {
        var sendUserId: String?
      
        init?(msgData: JSON) {
            self.sendUserId = msgData["fromUserId"].string
        }
        
        struct ScreenShotMsg {
            var sendUserId: String?

            func build() -> String {
                let params: [String: Any] = [
                    "msgType": "24",
                    "msgData": [
                        "fromUserId": sendUserId
                    ]
                ]
                guard let msg = JSON(params).rawString() else {
                    fatalError("JSON format error")
                }
                return msg
            }
        }
    }
}
