

import Foundation
import SwiftyJSON

class GroupReportService: NetworkRequest {
    
    class func fileUpload(file: Data,
                          completion: @escaping (BaseResult<(String), String>) -> Void) {
        let url = URL(string: API.Base.backend + API.Conversation.reportFilesUpload())!

        upload({ form in
            form.append("\(file.count)".utf8Data, withName: "size")
            form.append(file.zmMD5Digest(), withName: "md5")
            form.append(file, withName: "file", fileName: file.md5, mimeType: "image/jpeg")
        }, to: url, method: .put).responseDataErrorBeLocalized { response in
            switch response.result {
            case .failure(let err): completion(.failure(err.localizedDescription))
            case .success(let value):
                let json = JSON(value)["data"]
                if let url = json["url"].string {
                    completion(.success(url))
                } else {
                    completion(.failure("No URL returned"))
                }
            }
        }
    }
    
    
    class func report(cid: String, typ: Int, photos: [String], content: String,
                      completion: @escaping (BaseResult<(), String>) -> Void) {
        let url = URL(string: API.Base.backend + API.Conversation.report(cnvId: cid))!
        var urlRequest = try! URLRequest(url: url, method: .put)
        do {
            let data = try JSONSerialization.data(withJSONObject: ["typ": typ,
                                                                   "photos": photos,
                                                                   "content": content],
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
    
    class func unBlock(conversationId: String, content: String,
                       completion: @escaping (BaseResult<(), String>) -> Void) {
        let url = URL(string: API.Base.backend + API.Conversation.unblock(cnvId: conversationId))!
        var urlRequest = try! URLRequest(url: url, method: .put)
        do {
            let data = try JSONSerialization.data(withJSONObject: ["content": content],
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
    
}
