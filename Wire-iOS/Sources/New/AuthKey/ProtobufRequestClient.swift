


import Foundation
import WireDataModel
import SwiftProtobuf

protocol Parsable {
    static func parse(_ data: Data) -> Result<Self>
}

extension Parsable where Self: SwiftProtobuf.Message {
    static func parse(_ data: Data) -> Result<Self> {
        do {
            let model = try self.init(serializedData: data)
            return .success(model)
        } catch let error {
            return .failure(error)
        }
    }
}

extension ServerRes: Parsable {}

class ProtobufRequestClient {
    
    static let shared = ProtobufRequestClient()
    
    public func request<R: ProtobufRequestConvertible>(rqConvertible: R, completion: @escaping (Result<R.T>) -> Void) {
        var request = URLRequest(url: rqConvertible.url)
        request.httpMethod = "POST"
        request.httpBody = rqConvertible.httpBody
        request.addValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")
        request.addValue("application/x-protobuf", forHTTPHeaderField: "Accept")
        if let transportsession = ZMUserSession.shared()?.transportSession as? ZMTransportSession, let token = transportsession.accessToken?.token {
            request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        }
        guard let context = ZMUserSession.shared()?.managedObjectContext else {
            return
        }
        if let clientId = ZMUser.selfUser(in: context).selfClient()?.remoteIdentifier {
            request.addValue(clientId, forHTTPHeaderField: "Z-Client")
        }
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let e = error {
                print("error: \(e)")
                completion(.failure(e))
                return
            }
            guard let d = data else {
                return
            }
            let t = R.T.parse(d)
            completion(t)
        }
        task.resume()
    }
}
