//
//  API.swift
//  Wire-iOS
//

import Foundation

enum API {

    struct Base {
        static let backend = BackendEnvironment.shared.backendURL.absoluteString
        static func notContainUrl(with string: String) -> Bool {
            return !string.contains(backend)
        }
    }

    struct Users {
        static let userid = "/users"
        static let coreFriends = "/user/secret/memref"
    }
    
    struct User {
        static let privateId = "/self/extid"
        static let userInfo = "/users/by/extid/"
    }
    
    struct Expression {
        static let expression = "/thdmod/shortgif/setting"
    }
    
    struct Translation {
        static let translate = "/thdmod/google/translate/text"
    }
    
    struct Authkey {
        static let authkey = "/authkey/auth/answer"
    }

    struct Conversation {
        static let conversations = "/conversations"
        

        static func report(cnvId: String) -> String {
            return  "/judge/conversations/\(cnvId)/accusation"
        }
        

        static func unblock(cnvId: String) -> String {
            return  "/judge/conversations/\(cnvId)/appeal"
        }
        

        static func reportFilesUpload() -> String {
            return  "/judge/file"
        }
        

        static let bot = "/assistant/bot/message"
    }
    
    struct Scan {
        static let loginWeb = "/self/accept2d"
    }

    struct AppLoginAuth {
        static let apploginauth = "/self/apploginauth"
        static let updatepassword = "/self/password"
    }

    struct ThirdLoginAuth {
        static let thirdloginauth = "/login/thirdapp"
    }
    
    struct H5Auth {
        static let accept = "/self/secret/h5web2d/login/accept"
    }

    struct Friend {
        static let momentList   = "/moments/list"
        static let main         = "/moments/main"
        static let mainFile     = "/moments/photos"
    }
    

    struct Moment {
        static let single           = "/query"
        static let videos           = "/video"
        
        static let fileAuth         = "/file/auth"
        static let fileUpload       = "/file/upload"
        static let post             = "/post"
        
        static let delete           = "/delete"
        static let forward          = "/post"
        
        static let queryComments    = "/comment/query"
        static let addComment       = "/comment/add"
        static let delComment       = "/comment/del"
        
        static let addOpinion       = "/opinion/add"
        static let delOpinion       = "/opinion/del"
        
        static let commentOpinion   = "/comment/like"
        
        static let blockUser        = "/not_see"
        static let blockMoment      = "/not_see"
        static let blockUserList    = "/not_sees"
    }
    

    struct Notification {
        static let list             = "/moments/messages"
    }
    
    struct Location {
        static let getParse           = "/location/get"
        static let getSearchParse     = "/location/search"
    }
    

    struct GroupIcon {
        static let assets = "/assets/v3"
    }


    struct GroupManage {

 
        static func changeOwner(cnvId: String) -> String {
            return  "/conversations/\(cnvId)/creator"
        }

  
        static func conversationUpdate(cnvId: String) -> String {
            return "/conversations/\(cnvId)/update"
        }

  
        static func inviteVerify(cnvId: String) -> String {
            return "/conversations/\(cnvId)/invite/conf"
        }

 
        static func addContact(cnvId: String) -> String {
            return "/conversations/\(cnvId)/members/conf"
        }
    }

    struct AccountSecurity {
        static let accountInfo = "/thdmod/safety/master/account/info"
        static let bind = "/thdmod/safety/master/account/bind"
        static let unbind = "/thdmod/safety/master/account/unbind"
        static let emailCode = "/verify/send"
        static let confirm = "/thdmod/safety/work/permit"
    }
    
}
