
import Ziphy
import WireDataModel

extension ZMUserSession: ZiphyURLRequester {
    public func performZiphyRequest(_ request: URLRequest, completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> ZiphyRequestIdentifier {
        // Removing the https://host part from the given URL, so WireSyncEngine can prepend it with the Wire giphy proxy host
        // e.g. url = https://api.giphy.com/v1/gifs/trending?limit=50&offset=0
        //      requestPath = /v1/gifs/trending?limit=50&offset=0

        guard let requestPath = request.url?.urlWithoutSchemeAndHost else {
            preconditionFailure("request does not contain a valid URL")
        }

        return doRequest(withPath: requestPath,
                         method: .methodGET,
                         type: .giphy,
                         completionHandler: completionHandler)
    }

    public func cancelZiphyRequest(withRequestIdentifier requestIdentifier: ZiphyRequestIdentifier) {
        guard let requestIdentifier = requestIdentifier as? ProxyRequest else { return }
        cancelProxiedRequest(requestIdentifier)
    }

    private func doRequest(withPath path: String, method: ZMTransportRequestMethod, type: ProxiedRequestType, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> ProxyRequest {
        return proxiedRequest(withPath: path, method: method, type: type, callback: completionHandler)
    }

}

extension ProxyRequest: ZiphyRequestIdentifier {}
