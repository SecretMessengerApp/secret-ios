

import Foundation


protocol ProtobufRequestConvertible {
    associatedtype T: Parsable
    var url: URL { get }
    var method: String { get }
    var httpBody: Data? { get }
}

extension ProtobufRequestConvertible {
    var method: String {
        return "POST"
    }
    var url: URL {
        return URL(string: API.Base.backend + API.Authkey.authkey)!
//        return URL(string: "http://192.168.8.122:8089/api/auth/answer")!
    }
}

struct ReqPQRequest: ProtobufRequestConvertible {
    
    typealias T = ServerRes
    
    var httpBody: Data? {
        var cRq = ClientReq()
        var pq = ReqPQ()
        guard let data = AuthKeyHandler.shared.nonceData() else {
            return nil
        }
        pq.nonce = data
        cRq.content = .reqPq(pq)
        guard let crqData = try? cRq.serializedData() else {
            return nil
        }
        return crqData
    }
}

struct ReqDHParamsRequest: ProtobufRequestConvertible {
    
    typealias T = ServerRes
    
    var data: Data
    init(data: Data) {
        self.data = data
    }
    
    var httpBody: Data? {
        return self.data
    }
}

struct ReqClientDHParamsRequest: ProtobufRequestConvertible {
    
    typealias T = ServerRes
    
    var data: Data
    init(data: Data) {
        self.data = data
    }
    
    var httpBody: Data? {
        return self.data
    }

}
