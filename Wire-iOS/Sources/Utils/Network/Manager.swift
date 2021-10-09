//
//  NetworkManager.swift
//


import Foundation
import Alamofire

private let zmLog = ZMSLog(tag: "Network")


public enum NetworkRequestParameterEncoding {
    case json(NetworkJSONEncoding)
    case url(NetworkURLEncoding)

    public enum NetworkURLEncoding {
        case `default`, queryString, httpBody
    }

    public enum NetworkJSONEncoding {
        case `default`, prettyPrinted
    }

    var map: ParameterEncoding {
        switch self {
        case .json(let encoding):
            switch encoding {
            case .default:          return JSONEncoding.default
            case .prettyPrinted:    return JSONEncoding.prettyPrinted
            }
        case .url(let encoding):
            switch encoding {
            case .default:          return URLEncoding.default
            case .httpBody:         return URLEncoding.httpBody
            case .queryString:      return URLEncoding.queryString
            }
        }
    }
}



public enum NetworkDownloadRequestOption {
    
    case createIntermediateDirectories
    case removePreviousFile
    case createIntermediateDirectoriesAndRemovePreviousFile
    
    var map: DownloadRequest.Options {
        switch self {
        case .createIntermediateDirectories:
            return .createIntermediateDirectories
        case .removePreviousFile:
            return .removePreviousFile
        case .createIntermediateDirectoriesAndRemovePreviousFile:
            return [.createIntermediateDirectories, .removePreviousFile]
        }
    }
}


// MARK: - NetworkManager
class NetworkManager {
    
    static let manager = NetworkManager()

    private init() {}

    private let sessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        return Session(
            configuration: configuration,
            interceptor: AcceccTokenAdapter(),
            eventMonitors: [LogEventMonitor()]
        )
    }()

    func request(
        _ url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?,
        interceptor: RequestInterceptor?,
        requestModifier: Session.RequestModifier?
    ) -> DataRequest {
        sessionManager.request(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers,
            interceptor: interceptor,
            requestModifier: requestModifier
        )
    }

    func request(
        _ urlRequest: URLRequestConvertible,
        interceptor: RequestInterceptor? = nil
    ) -> DataRequest {
        sessionManager.request(urlRequest, interceptor: interceptor)
    }
    
    func upload(
        _ data: Data,
        to convertible: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil,
        fileManager: FileManager,
        interceptor: RequestInterceptor? = nil,
        requestModifier: Session.RequestModifier?
    ) -> UploadRequest {
        sessionManager.upload(
            data,
            to: convertible,
            method: method,
            headers: headers,
            interceptor: interceptor,
            fileManager: fileManager,
            requestModifier: requestModifier
        )
    }
    
    func upload(
        _ multipartFormData: @escaping (MultipartFormData) -> Void,
        usingThreshold: UInt64,
        fileManager: FileManager,
        to url: URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders?,
        interceptor: RequestInterceptor?,
        requestModifier: Session.RequestModifier?
    ) -> UploadRequest {
        sessionManager.upload(
            multipartFormData: multipartFormData,
            to: url,
            usingThreshold: usingThreshold,
            method: method,
            headers: headers,
            interceptor: interceptor,
            fileManager: fileManager,
            requestModifier: requestModifier
        )
    }
    
    func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        usingThreshold encodingMemoryThreshold: UInt64,
        fileManager: FileManager,
        with request: URLRequestConvertible,
        interceptor: RequestInterceptor?
    ) -> UploadRequest {
        let formData = MultipartFormData(fileManager: fileManager)
        multipartFormData(formData)
        return sessionManager.upload(
            multipartFormData: formData,
            with: request,
            usingThreshold: encodingMemoryThreshold,
            interceptor: interceptor,
            fileManager: fileManager
        )
    }
    
    func download(
        _ urlRequest: URLRequestConvertible,
        interceptor: RequestInterceptor?,
        to destination: DownloadRequest.Destination?
    ) -> DownloadRequest {
        sessionManager.download(
            urlRequest,
            interceptor: interceptor,
            to: destination
        )
    }
    
    func download(
        _ url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?,
        interceptor: RequestInterceptor?,
        requestModifier: Session.RequestModifier?,
        to destination: DownloadRequest.Destination?
    ) -> DownloadRequest {
        sessionManager.download(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers,
            interceptor: interceptor,
            requestModifier: requestModifier,
            to: destination
        )
    }
}


// MARK: - AcceccTokenAdapter
private class AcceccTokenAdapter: RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Swift.Result<URLRequest, Error>) -> Void) {
        if let url = urlRequest.url, API.Base.notContainUrl(with: url.absoluteString) {
            completion(.success(urlRequest))
            return
        }
        
        var urlRequest = urlRequest
        if let transportsession = ZMUserSession.shared()?.transportSession as? ZMTransportSession, let token = transportsession.accessToken?.token {
            urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        }
        let headers = ["Accept": "application/json",
                       "Content-Type": "application/json"]
        urlRequest.allHTTPHeaderFields?.merge(headers) { (old, _) in old }
        completion(.success(urlRequest))
    }
}


// MARK: - Log
private class LogEventMonitor: EventMonitor {
    
    func request(_ request: Request, didCreateTask task: URLSessionTask) {
        zmLog.safePublic(SanitizedString(stringLiteral: "SecretRequest: \(request)"))
        zmLog.info("----> SecretRequest: \n\(request.cURLDescription())")
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let request = dataTask.currentRequest,
            let response = dataTask.response as? HTTPURLResponse,
            let method = request.method {
            zmLog.safePublic(SanitizedString(stringLiteral: "SecretResponse to \(request) method:\(method) status:\(response.statusCode)"))
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                zmLog.info("<---- SecretResponse to \(response) \n\(json)")
            }

        }
        zmLog.info("SecretURL Session is \(session.description)")
    }
}
