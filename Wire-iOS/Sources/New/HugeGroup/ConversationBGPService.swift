//
//  ConversationSettingService.swift
//  Wire-iOS
//

import Foundation
import SwiftyJSON

class ConversationBGPService: NetworkRequest {
    
    class func toBGP(conversationId: String,
                     completion: @escaping (BaseResult<(), String>) -> Void) {
        let url = URL(string: API.Base.backend + API.Conversation.conversations + "/\(conversationId)/newtype")!
        var urlRequest = try! URLRequest(url: url, method: .put)
        do {
            let data = try JSONSerialization.data(withJSONObject: ["type": 5],
                                                  options: .prettyPrinted)
            urlRequest.httpBody = data
        } catch { completion(.failure(error.localizedDescription)) }
        request(urlRequest).responseDataErrorBeLocalized { response in
            switch response.result {
            case .success: completion(.success)
            case .failure(let err): completion(.failure(err.localizedDescription))
            }
        }
    }
    
    class func membersCount(id: String,
                            completion: @escaping (BaseResult<Int?, String>) -> Void) {
        let path = API.Base.backend + API.Conversation.conversations + "/\(id)/count_members"
        request(path).responseDataErrorBeLocalized { response in
                switch response.result {
                case .success(let value):
                    completion(.success(JSON(value)["memsum"].int))
                case .failure(let err):
                    completion(.failure(err.localizedDescription))
                }
        }
    }
    

    class func members(
        cid: String,
        start: String? = nil, size: UInt = 50,
        completion: @escaping (BaseResult<[ConversationBGPMemberModel], String>) -> Void
        ) {
        var path = API.Base.backend + API.Conversation.conversations + "/\(cid)/members?size=\(size)"
        if let start = start {
            path += "&start=\(start)"
        }
        request(path).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let array = JSON(value)["conversations"].array {
                    let members = array.map { ConversationBGPMemberModel(json: $0) }
                    completion(.success(members))
                } else {
                    completion(.success([]))
                }
            case .failure(let err):
                completion(.failure(err.localizedDescription))
                
            }
        }
    }
    
    class func inviters(cid: String, completion: @escaping (BaseResult<(inviteMe: [ZMUser], meInvite: [ZMUser]), String>) -> Void) {
        let path = API.Base.backend + API.Conversation.conversations + "/\(cid)/memref/self"
        request(path).responseJSON { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)["data"]
                var inviteMe: [ZMUser] = []
                if  let id = json["parent"]["id"].string,
                    let uuid = UUID(uuidString: id),
                    let user = ZMUser(remoteID: uuid) {
                    inviteMe = [user]
                }
                let meInvite = json["children"].array?.map { json -> ZMUser? in
                    guard
                        let id = json["id"].string,
                        let uuid = UUID(uuidString: id),
                        let user = ZMUser(remoteID: uuid)
                        else { return nil }
                     return user
                }
                .filter { $0 != nil }
                .map{ $0! }
                ?? []
                completion(.success((inviteMe, meInvite)))
            case .failure(let err):
                completion(.failure(err.localizedDescription))
            }
        }
    }
    
    class func users(by ids: [String], completion: @escaping (BaseResult<[BGPUserModel], String>) -> Void) {
        let ids = ids.joined(separator: ",")
        let url = API.Base.backend + API.Users.userid + "?ids=\(ids)"
        request(url).responseJSON { response in
            if let data = response.data {
                let models = JSON(data).array?.map { BGPUserModel(json: $0) } ?? []
                completion(.success(models))
            } else {
                completion(.failure(response.error!.localizedDescription))
            }
        }
    }
    
    class func getUsers(convid: String?, searchValue: String?, completion: @escaping (BaseResult<[ConversationBGPMemberModel], String>) -> Void) {
        guard let cid = convid, let name = searchValue else {return}
        let url = API.Base.backend + API.Conversation.conversations + "/\(cid)" + "/search?q=" + name + "&size=100"
        request(url).responseData { (response) in
            switch response.result {
            case .failure(let err): completion(.failure(err.localizedDescription))
            case .success(let data):
                let json = try? JSON(data: data)
                let items = json?.array?.map { ConversationBGPMemberModel(json: $0) }                
                completion(.success(items ?? []))
            }
        }
    }
}
