//
//  ConversationAppShareModel.swift
//  Wire-iOS

import Foundation
import SwiftyJSON

protocol ShareContentM {
    init(json: JSON)
}

struct ConversationAppShareModel {
    
    enum ShareType {
        case infos(InfosM)
        case article(ArticleM)
        case image(ImageM)
        case video(VideoM)
        case audio(AudioM)
        case text(TextM)
        case unknown
        
        var needCreateAuthor: Bool {
            switch self {
            case .image, .video, .audio, .text:
                return true
            default:
                return false
            }
        }
    }
    
    struct TextM: ShareContentM {
        let author: Author
        let content: String
        
        init(json: JSON) {
            self.content    = json["content"].stringValue
            self.author     = Author(json: json)
        }
    }
    
    struct ImageM: ShareContentM {
        let author: Author
        let picture: String
        let summary: String
        
        init(json: JSON) {
            self.summary    = json["summary"].stringValue
            self.picture    = json["picture"].stringValue
            self.author     = Author(json: json["author"])
        }
    }
    
    struct AudioM: ShareContentM {
        let author: Author
        let duration: String
        let summary: String
        
        init(json: JSON) {
            self.summary    = json["summary"].stringValue
            self.duration   = json["duration"].stringValue
            self.author     = Author(json: json)
        }
    }
    
    struct VideoM: ShareContentM {
        let author: Author
        let picture: String
        let summary: String
        
        init(json: JSON) {
            self.summary    = json["summary"].stringValue
            self.picture    = json["picture"].stringValue
            self.author     = Author(json: json["author"])
        }
    }
    
    struct ArticleM: ShareContentM {
        let picture: String
        let title: String
        let summary: String
        
        init(json: JSON) {
            self.title          = json["title"].stringValue
            self.picture        = json["picture"].stringValue
            self.summary        = json["summary"].stringValue
        }
    }
    
    struct InfosM: ShareContentM {
        let image: String
        let title: String
        let info: [[String: String]]
        
        init(json: JSON) {
            self.title      = json["title"].stringValue
            self.image      = json["image"].stringValue
            self.info       = json["info"].arrayObject as! [[String: String]]
        }
    }
    
    struct Author {
        let userID: String
        let name: String
        let header: String
        let orginalTime: String
        init(json: JSON) {
            self.userID         = json["fromUserId"].stringValue
            self.name           = json["fromUserName"].stringValue
            self.header         = json["fromUserRAssetId"].stringValue
            self.orginalTime    = json["orginalTime"].stringValue
        }
    }
    
    
    let shareType: ShareType

    let appId: String
    let appName: String
    let appLogo: String
    
    init(_ jsonString: String) {
        self.init(json: JSON(parseJSON: jsonString))
    }
    
    init(json: JSON) {
        let type        = json["msgType"].intValue
        self.appId      = json["msgData"]["appId"].stringValue
        self.appName    = json["msgData"]["appName"].stringValue
        self.appLogo    = json["msgData"]["appLogo"].stringValue
        
        switch type {
        case 13:
            self.shareType = .infos(InfosM(json: json["msgData"]))
        case 14:
            self.shareType = .article(ArticleM(json: json["msgData"]))
        case 15:
            self.shareType = .image(ImageM(json: json["msgData"]))
        case 16:
            self.shareType = .video(VideoM(json: json["msgData"]))
        case 17:
            self.shareType = .audio(AudioM(json: json["msgData"]))
        case 18:
            self.shareType = .text(TextM(json: json["msgData"]))
        default:
            self.shareType = .unknown
        }
    }
    
}
