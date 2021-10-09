//
//  ThridAppLoginAuthService.swift
//  Wire-iOS
//

import UIKit
import SwiftyJSON

class AuthLoginService: NetworkRequest {
    
    static func appLoginAuth(appid: String, key: String, completion: @escaping (BaseResult<JSON, String>) -> Void) {
        request(API.Base.backend + API.AppLoginAuth.apploginauth, method: .post,
                parameters: ["appid": appid, "key": key],
                encoding: .json(.default))
            .responseDataErrorBeLocalized { (response) in
                switch response.result {
                case .success(let data): completion(.success(JSON(data)))
                case .failure(let err): completion(.failure(err.localizedDescription))
                }
        }
    }
    
    
    static func appThirdLoginAuth( fromid: String,
                                   email: String,
                                   userid: String,
                                   label: String,
                                   password: String? = nil,
                                   completion: @escaping (ThridLoginResult<JSON, [AnyHashable: Any], String, HTTPURLResponse, String>) -> Void) {
        let passwordParameter: [String: Any] = password == nil ? [:] : ["password": password!]
        let path = API.Base.backend + API.ThirdLoginAuth.thirdloginauth
        let request = ZMTransportRequest(path: path, method: .methodPOST, payload: ["fromid": fromid, "email": email, "label": label, "userid": userid].updated(other: passwordParameter) as ZMTransportData , authentication: .needsAccess)
        request.addValue("application/json", forAdditionalHeaderField: "Content-Type")
        guard let context = ZMUserSession.shared()?.managedObjectContext else {return}
        request.add(ZMCompletionHandler(on: context, block: { (response) in
            guard let payload = response.payload else {return}
            guard let responsedic = payload.asDictionary() as? [String: Any] else {return}
            let responseJson = JSON(responsedic)
            guard responseJson["code"].intValue == 200 else {
                completion(.loginFailure(""))
                return
            }
            completion(.loginSuccess(responseJson, response.headers, response.rawResponse, path))
        }))
        SessionManager.shared?.activeUserSession?.transportSession.enqueueOneTime(request)
    }
    
    static func updatePassword(oldPassword: String, newPassword: String, token: String, completion: @escaping (BaseResult<JSON, String>) -> Void) {
        request(API.Base.backend + API.AppLoginAuth.updatepassword, method: .put,
                parameters: ["old_password": oldPassword, "new_password": newPassword],
                encoding: .json(.default), headers: ["Authorization": "Bearer "+token])
            .responseDataErrorBeLocalized { (response) in
                switch response.result {
                case .success(let data): completion(.success(JSON(data)))
                case .failure(let err): completion(.failure(err.localizedDescription))
                }
        }
    }
    
    enum ThridLoginResult<S, H, F, R, U> {
        case loginSuccess(S, H?, R?, U)
        case loginFailure(F)
    }
    
}
