//
//  GroupManageService.swift
//  Wire-iOS
//

import Foundation
import SwiftyJSON

final class GroupManageService: NetworkRequest {

    class func creatorVerify(cnvId: String, code: String, allow: Bool, completion: @escaping (BaseResult<Void, String>) -> Void) {

        let url = API.Base.backend + API.GroupManage.inviteVerify(cnvId: cnvId)
        request(url,
                method: .post,
                parameters: ["code": code, "allow": allow],
                encoding: .json(.default)
            ).responseDataErrorBeLocalized { response in
                switch response.result {
                case .success:
                    completion(.success)
                case .failure(let err):
                    completion(.failure(err.localizedDescription))
                }
        }
    }

    class func addContact(cnvId: String, users: [String], reason: String, name: String, completion: @escaping (BaseResult<Bool, String>) -> Void) {

        let url = API.Base.backend + API.GroupManage.addContact(cnvId: cnvId)
        request(url,
                method: .post,
                parameters: ["users": users, "reason": reason, "name": name],
                encoding: .json(.default)
            ).responseDataErrorBeLocalized { response in
                switch response.result {
                case .success(let value):
                    completion(.success(JSON(value)["code"].intValue == 200))
                case .failure(let err):
                    completion(.failure(err.localizedDescription))
                }
        }
    }

    ///conversation
    class func gorupUpdate(cnvId: String, previewKey: String, completeKey: String, completion: @escaping (BaseResult<JSON, String>) -> Void) {

        let param: [String: Any] = ["assets": [["type": "image", "key": previewKey, "size": "preview"], ["type": "image", "key": completeKey, "size": "complete"]]]
        let url = API.Base.backend + API.GroupManage.conversationUpdate(cnvId: cnvId)
        request(url,
                method: .put,
                parameters: param,
                encoding: .json(.default)
            ).responseDataErrorBeLocalized { response in
                switch response.result {
                case .success(let value):
                    completion(.success(JSON(value)))
                case .failure(let err):
                    completion(.failure(err.localizedDescription))
                }
        }
    }
    

    class func innviteUrl(id: String,
                          completion: @escaping (BaseResult<String, String>) -> Void) {
        let url = API.Base.backend + API.Conversation.conversations + "/\(id)/invite/url"
        request(url, method: .post)
            .responseDataErrorBeLocalized { response in
                switch response.result {
                case .success(let value):
                    completion(.success(JSON(value)["data"]["inviteurl"].stringValue))
                case .failure(let err):
                    completion(.failure(err.localizedDescription))
                }
        }
    }
    

    class func joinAndCompletionData(id: String,
                    completionData: @escaping (Data?) -> Void) {
        let url = API.Base.backend + API.Conversation.conversations + "/\(id)/join_invite"
        request(url, method: .post).response { response in
            completionData(response.data)
        }
    }
    
    class func join(id: String,
                    completion: @escaping (BaseResult<String, String>) -> Void) {
        joinAndCompletionData(id: id) { (data) in
            if let data = data {
                let json = JSON(data)
                if let cid = json["conversation"].string {
                    completion(.success(cid))
                } else if let cid = json["data"]["conv"].string {
                    completion(.success(cid))
                } else if let code = json["code"].int, code == 2002 {
                    completion(.failure("join_invite_response_error_code_2002".localized))
                } else {
                    completion(.failure("secret_unknown_error".localized))
                }
            } else {
                completion(.failure("secret_unknown_error".localized))
            }
        }
    }
    
    enum JoinConversationCheckState {
        case alreadyIn(String)
        case warning
        case lock
        case willIn
    }
    
    class func joinCheck(
        inviteId: String,
        completion: @escaping (BaseResult<JoinConversationCheckState, String>) -> Void
        ) {
        let url = API.Base.backend + API.Conversation.conversations + "/\(inviteId)/invite/url/check"

        request(url).responseJSON { response in
            if let data = response.data, response.error == nil {
                let json = JSON(data)
                if let cid = json["data"]["conv"].string, json["code"].intValue == 2001 {
                    completion(.success(.alreadyIn(cid)))
                } else if json["code"].intValue == 2004 {
                    completion(.success(.warning))
                } else if json["code"].intValue == 2005 {
                    completion(.success(.lock))
                } else if json["code"].intValue == 2003 {
                    completion(.success(.willIn))
                }
            } else {
                completion(.failure("secret_unknown_error".localized))
            }
        }
    }
    

    class func beJoin(id: String, inviteid: String,
                      completion: @escaping (BaseResult<Void, String>) -> Void) {
        let url = API.Base.backend + API.Conversation.conversations + "/\(id)/\(inviteid)/member_join_confirm"
        request(url, method: .post).responseDataErrorBeLocalized { response in
            switch response.result {
            case .success: completion(.success)
            case .failure(let err):
                completion(.failure(err.localizedDescription))
            }
        }
    }
}
