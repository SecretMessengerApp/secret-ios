//
//  NetworkRequest.swift
//  Wire-iOS
//
import Alamofire

public protocol NetworkRequest {}


// MARK: - Decodable
extension NetworkRequest {

    @discardableResult
    static func request<D: Decodable>(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        model: D.Type,
        parameters: Parameters? = nil,
        encoding: NetworkRequestParameterEncoding = .url(.default),
        headers: HTTPHeaders? = nil,
        completion: @escaping (DataResponse<D, Error>) -> Void
    ) -> DataRequest {
        request(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
        ).responseDecodable(completion)
    }

    @discardableResult
    static func request<D: Decodable>(
        _ urlRequest: URLRequestConvertible,
        model: D.Type,
        completion: @escaping (DataResponse<D, Error>) -> Void
    ) -> DataRequest {
        request(urlRequest).responseDecodable(completion)
    }
}


// MARK: - Modeable
extension NetworkRequest {
    
    @discardableResult
    static func request<T: Modelable>(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        model: T.Type,
        parameters: Parameters? = nil,
        encoding: NetworkRequestParameterEncoding = .url(.default),
        headers: HTTPHeaders? = nil,
        completion: @escaping (DataResponse<T, Error>) -> Void
    ) -> DataRequest {
        request(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
        )
        .responseModelable(completion)
    }

    @discardableResult
    static func request<T: Modelable>(
        _ urlRequest: URLRequestConvertible,
        model: T.Type,
        completion: @escaping (DataResponse<T, Error>) -> Void
    ) -> DataRequest {
        return request(urlRequest).responseModelable(completion)
    }
}


// MARK: - Normal
extension NetworkRequest {

    @discardableResult
    static func request(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: NetworkRequestParameterEncoding = .url(.default),
        headers: HTTPHeaders? = nil
    ) -> DataRequest {
        NetworkManager.manager.request(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding.map,
            headers: headers,
            interceptor: nil,
            requestModifier: nil
        )
    }

    @discardableResult
    static func request(_ urlRequest: URLRequestConvertible) -> DataRequest {
        return NetworkManager.manager.request(urlRequest)
    }
}


// MARK: - Upload
extension NetworkRequest {

    static func upload(
        _ multipartFormData: @escaping (MultipartFormData) -> Void,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil
    ) -> UploadRequest {
        NetworkManager.manager.upload(
            multipartFormData,
            usingThreshold: MultipartFormData.encodingMemoryThreshold,
            fileManager: .default,
            to: url,
            method: method,
            headers: headers,
            interceptor: nil,
            requestModifier: nil
        )
    }

    static func upload(
        _ multipartFormData: @escaping (MultipartFormData) -> Void,
        with urlRequest: URLRequestConvertible
    ) -> UploadRequest {
        NetworkManager.manager.upload(
            multipartFormData: multipartFormData,
            usingThreshold: MultipartFormData.encodingMemoryThreshold,
            fileManager: .default,
            with: urlRequest,
            interceptor: nil
        )
    }
    
    static func upload(
        _ data: Data,
        to convertible: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil,
        interceptor: RequestInterceptor? = nil
    ) -> UploadRequest {
        NetworkManager.manager.upload(
            data,
            to: convertible,
            method: method,
            headers: headers,
            fileManager: .default,
            interceptor: interceptor,
            requestModifier: nil
        )
    }
}


// MARK: - Download
extension NetworkRequest {
    
    @discardableResult
    static func download(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: NetworkRequestParameterEncoding = .url(.default),
        headers: HTTPHeaders? = nil,
        to destinationURL: URL,
        option: NetworkDownloadRequestOption
    ) -> DownloadRequest {
        let destination: DownloadRequest.Destination = { _, _ in
            (destinationURL, option.map)
        }
        return NetworkManager.manager.download(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding.map,
            headers: headers,
            interceptor: nil,
            requestModifier: nil,
            to: destination
        )
    }
}
