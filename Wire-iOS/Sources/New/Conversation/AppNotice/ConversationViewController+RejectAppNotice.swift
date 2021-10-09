//
//  ConversationViewController+RejectAppNotice.swift
//  Wire-iOS

import Foundation

extension ConversationViewController {
    
    func rejectAppNotice(appID: String, completion: @escaping (Bool) -> Void) {
        RejectAppNoticeService.reject(appID: appID) { result in
            switch result {
            case .success: completion(true)
            case .failure: completion(false)
            }
        }
    }
}

private class RejectAppNoticeService: NetworkRequest {
    
    ///
    /// block=true:
    /// block=false: 
    class func reject(appID: String, completion: @escaping (BaseResult<(), String>) -> Void) {
        
        let url = API.Base.backend + "/self/block/\(appID)/service/notify?block=true"
        request(url, method: .put)
            .responseData { response in
                switch response.result {
                case .success:
                    completion(.success)
                case .failure(let err):
                    completion(.failure(err.localizedDescription))
                }
        }
    }
    
}
