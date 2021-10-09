
import Foundation
import Ziphy

extension ZiphyClient {

    static var `default`: ZiphyClient {
        return ZiphyClient(host: "api.giphy.com", requester: ZMUserSession.shared()!, downloadSession: URLSession.shared)
    }

}
