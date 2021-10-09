//
//  GoogleVerificationService.swift
//  Wire-iOS
//
//  Created by kk on 2018/8/21.
//  Copyright © 2018 Zeta Project Germany GmbH. All rights reserved.
//

import UIKit
import SwiftyJSON

class GoogleVerificationService: NetworkRequest {

    class func check(_ completion: @escaping (BaseResult<GoogleVerificationCheck.State, String>) -> Void) {
        request(APILink.Base.backend + APILink.Google.check,
                model: BaseModel<GoogleVerificationCheck>.self) { (response) in
            switch response.result {
            case .success(let model): completion(.success(model.data?.status ?? .never))
            case .failure(let err):
                completion(.failure(err.localizedDescription))
            }
        }
    }

    class func turnOff(_ completion: @escaping (BaseResult<(), String>) -> Void) {
        request(APILink.Base.backend + APILink.Google.off, method: .post).responseError { response in
            switch response.result {
            case .success: completion(.success())
            case .failure(let err): completion(.failure(err.localizedDescription))
            }
        }
    }

    class func turnOn(code: String, completion: @escaping (BaseResult<(), String>) -> Void) {
        let url = URL(string: APILink.Base.backend + APILink.Google.on)!
        var urlRequest = try! URLRequest(url: url, method: .post)
        let json = "\"" + code + "\""
        urlRequest.httpBody = json.data(using: .utf8)
        request(urlRequest).responseError { response in
            switch response.result {
            case .success: completion(.success())
            case .failure(let err): completion(.failure(err.localizedDescription))
            }
        }
    }

    class func send(_ completion: @escaping (BaseResult<(), String>) -> Void) {

        let url = URL(string: APILink.Base.backend + APILink.Google.send)!
        var urlRequest = try! URLRequest(url: url, method: .post)
        let para = ["email": ZMUser.selfUser().emailAddress]
        do {
            let data = try JSONSerialization.data(withJSONObject: para,
                                                  options: .prettyPrinted)
            urlRequest.httpBody = data
        } catch { completion(.failure(error.localizedDescription)) }

        request(urlRequest).responseError { response in
            switch response.result {
            case .success: completion(.success())
            case .failure(let err): completion(.failure(err.localizedDescription))
            }
        }
    }

    class func ecode(code: String,
                     _ completion: @escaping (BaseResult<(), String>) -> Void) {

        let url = URL(string: APILink.Base.backend + APILink.Google.ecode)!
        var urlRequest = try! URLRequest(url: url, method: .post)
        let para = ["email": ZMUser.selfUser().emailAddress, "code": code]
        do {
            let data = try JSONSerialization.data(withJSONObject: para, options: .prettyPrinted)
            urlRequest.httpBody = data
        } catch { completion(.failure(error.localizedDescription)) }

        request(urlRequest).responseError { response in
            switch response.result {
            case .success: completion(.success())
            case .failure(let err): completion(.failure(err.localizedDescription))
            }
        }
    }

    class func create(_ completion: @escaping (BaseResult<GoogleVerificationCreate, String>) -> Void) {
        request(APILink.Base.backend + APILink.Google.create, method: .post).responseError { response in
            switch response.result {
            case .success(let data):
                let model = GoogleVerificationCreate(json: JSON(data))
                completion(.success(model))
            case .failure(let err): completion(.failure(err.localizedDescription))
            }
        }
    }

    class func verify(code: String,
                      pubkey: String? = nil,
                      completion: @escaping (BaseResult<(), String>) -> Void) {

        let url = URL(string: APILink.Base.backend + APILink.Google.verify)!
        var urlRequest = try! URLRequest(url: url, method: .post)
        guard let code = Int(code) else {
            completion(.failure("Code Error"))
            return
        }
        var para: [String: Any] = ["code": code]
        if let pb = pubkey {
            para["pubkey"] = pb
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: para, options: .prettyPrinted)
            urlRequest.httpBody = data
        } catch { completion(.failure(error.localizedDescription)) }

        request(urlRequest).responseError { (response) in
            switch response.result {
            case .success: completion(.success())
            case .failure(let err): completion(.failure(err.localizedDescription))
            }
        }
    }

}
