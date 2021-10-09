

import UIKit
import SwiftyJSON

class PrivateIdentifierService: NetworkRequest {
    
    class func getSelfPrivateIdentifier(completion: @escaping (BaseResult<JSON, String>) -> Void) {
        request(API.Base.backend + API.User.privateId, method: .get)
            .responseDataErrorBeLocalized { (response) in
                switch response.result {
                case .success(let data): completion(.success(JSON(data)))
                case .failure(let err): completion(.failure(err.localizedDescription))
                }
        }
    }
    
    class func getUserInfoWithPrivateIdentifier(_ id: String,completion: @escaping (BaseResult<JSON, String>) -> Void) {
        request(API.Base.backend + API.User.userInfo + id, method: .get)
            .responseDataErrorBeLocalized { (response) in
                switch response.result {
                case .success(let data): completion(.success(JSON(data)))
                case .failure(let err): completion(.failure(err.localizedDescription))
                }
        }
    }
}
