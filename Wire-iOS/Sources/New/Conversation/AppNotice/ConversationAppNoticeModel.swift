//
//  ConversationAppNoticeModel.swift
//  Wire-iOS

import Foundation
import SwiftyJSON

struct ConversationAppNoticeModel: Modelable {
    var logo: String?
    var cid: String
    var appID: String
    var name: String?
    var title: String?
    var info: [Item]
    var uid: String?
    
    var actionType: ActionType
    
    var content: String {
        return json["msgData"]["info"].rawString() ?? ""
    }
    
    init(_ jsonString: String) {
        self.init(json: JSON(parseJSON: jsonString))
    }
    
    private var json: JSON
    
    init(json: JSON) {
        self.json = json
        self.logo = json["msgData"]["icon"].string
        self.cid = json["msgData"]["conv"].stringValue
        self.appID = json["msgData"]["app_id"].stringValue
        self.name = json["msgData"]["name"].string
        self.title = json["msgData"]["title"].string
        self.info = json["msgData"]["info"].array?.map {
            Item(json: $0)
        } ?? []
        
        self.uid = json["msgData"]["uid"].string
        self.actionType = ActionType(msgType: json["msgType"].string)
    }
    
    enum ActionType {
        case addFriend
        case enterConversation
        case enterApps
        case rejectNotis
        
        init(msgType: String?) {
            if msgType == "20008" {
                self = .addFriend
            } else {
                self = .enterApps
            }
        }
        
        var title: String {
            switch self {
            case .addFriend:
                return "Click add friend"
            case .enterConversation:
                return "Click to enter group chat"
            case .enterApps:
                return "Click to enter the group application"
            case .rejectNotis:
                return "Reject this app notification"
            }
        }
    }
    
    
    struct Item {
        var key, value: String
        var type: ItemType = .normalString
        
        enum ItemType {
            case time
            case normalString
            case normalStringWithTime
            case unknown
            
            init(value: Int) {
                switch value {
                case 1: self = .time
                case 2: self = .normalString
                case 3: self = .normalStringWithTime
                default: self = .unknown
                }
            }
        }
        
        init(json: JSON) {
            self.type = ItemType(value: json["type"].intValue)
            self.key = json["key"].stringValue
            
            switch type {
            case .time:
                self.value = TimeInterval(json["value"].intValue).dateText() ?? ""
                
            case .normalStringWithTime:
                self.value = json["value"].array?.map {
                    Item(json: $0).value
                }
                .joined(separator: " ") ?? ""
                
            default:
                self.value = json["value"].stringValue
            }
        }
    }
}

extension TimeInterval {
    /// TimeInterval => Date
    /// - Parameter format: date format, default is yyyy-MM-dd hh:MM:ss
    func dateText(_ fromat: String = "yyyy-MM-dd HH:mm:ss") -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = fromat
        return formatter.string(from: Date(timeIntervalSince1970: self))
    }
}
