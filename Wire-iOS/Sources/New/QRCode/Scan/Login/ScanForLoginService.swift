//
//  ScanDesktopLoginService.swift
//  Wire-iOS
//

import UIKit

class ScanForLoginService: NetworkRequest {

    class func login(qrString: String,
                     completion: @escaping (BaseResult<(), String>) -> Void) {

        let url = URL(string: API.Base.backend + API.Scan.loginWeb)!
        var urlRequest = try! URLRequest(url: url, method: .put)
        urlRequest.httpBody = qrString.data(using: .utf8)

        request(urlRequest).response { response in
            switch response.result {
            case .success: completion(.success)
            case .failure(let err): completion(.failure(err.localizedDescription))
            }
        }
    }
}
