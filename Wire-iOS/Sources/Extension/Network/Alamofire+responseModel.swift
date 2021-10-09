//
//  Alamofire+responseModelable.swift
//  Wire-iOS
//


import Alamofire
import SwiftyJSON


// MARK: - responseModelable / responseDecodable
extension DataRequest {
    
    @discardableResult
    func responseModelable<T: Modelable>(
        _ completion: @escaping (DataResponse<T, Error>) -> Void
    ) -> DataRequest {
        errorBeMappedResponse(
            responseSerializer: ModelableDataResponseSerializer<T>(),
            completionHandler: completion
        )
    }
    
    @discardableResult
    func responseDecodable<D: Decodable>(
        _ completion: @escaping (DataResponse<D, Error>) -> Void
    ) -> DataRequest {
        errorBeMappedResponse(
            responseSerializer: DecodableDataResponseSerializer<D>(),
            completionHandler: completion
        )
    }
}

// MARK: - responseDataErrorBeLocalized / responseJSONErrorBeLocalized
extension DataRequest {
    
    @discardableResult
    func responseDataErrorBeLocalized(
        _ completion: @escaping (DataResponse<Data, Error>) -> Void
    ) -> DataRequest {
        errorBeMappedResponse(
            responseSerializer: ErrorDataResponseSerializer(),
            completionHandler: completion
        )
    }
    
    @discardableResult
    func responseJSONErrorBeLocalized(
        _ completion: @escaping (DataResponse<[String: Any], Error>) -> Void
    ) -> DataRequest {
        errorBeMappedResponse(
            responseSerializer: ErrorJSONResponseSerializer(),
            completionHandler: completion
        )
    }
}

// MARK: - errorBeMappedResponse
extension DataRequest {
    
    private func errorBeMappedResponse<Serializer: DataResponseSerializerProtocol>(
        responseSerializer: Serializer,
        completionHandler: @escaping (DataResponse<Serializer.SerializedObject, Error>) -> Void
    ) -> DataRequest {
        response(responseSerializer: responseSerializer) { dataResponse in
            let errorMappedDataResponse = dataResponse.mapError { $0.underlyingError ?? $0 }
            completionHandler(errorMappedDataResponse)
        }
    }
}


// MARK: - DataResponseSerializer
private class DataResponseSerializer {
    
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> Data {
        guard error == nil else { throw error! }
        
        guard let data = data, !data.isEmpty else {
            throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        }
        
        do {
            let json = try JSON(data: data)
            let code = json["code"].intValue
            if code == 200 {
                return data
            } else {
                throw NetworkError(path: request?.url?.path, code: code, data: json.dictionaryObject)
            }
        } catch {
            throw error
        }
    }
}

// MARK: - DecodableDataResponseSerializer
private class DecodableDataResponseSerializer<T: Decodable>: DataResponseSerializer, DataResponseSerializerProtocol {
    
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> T {
        do {
            let data = try super.serialize(request: request, response: response, data: data, error: error)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw error
        }
    }
    
    typealias SerializedObject = T
}

// MARK: - ModelableDataResponseSerializer
private class ModelableDataResponseSerializer<T: Modelable>: DataResponseSerializer, DataResponseSerializerProtocol {
    
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> T {
        do {
            let data = try super.serialize(request: request, response: response, data: data, error: error)
            return T(json: try JSON(data: data))
        } catch {
            throw error
        }
    }
    
    typealias SerializedObject = T
}

// MARK: - ErrorDataResponseSerializer
private class ErrorDataResponseSerializer: DataResponseSerializerProtocol {
    
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> Data {
        guard error == nil else { throw error! }
        
        guard let data = data, !data.isEmpty else {
            throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        }
        
        do {
            let json = try JSON(data: data)
            
            if let code = json["code"].int, code != 200 {
                throw NetworkError(path: request?.url?.path, code: code, data: json.dictionaryObject)
            } else {
                return data
            }
        } catch {
            throw error
        }
    }
}

// MARK: - ErrorJSONResponseSerializer
private class ErrorJSONResponseSerializer: DataResponseSerializer, DataResponseSerializerProtocol {
    
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> [String: Any] {
        do {
            let data = try super.serialize(request: request, response: response, data: data, error: error)
            return try JSON(data: data)["data"].dictionaryObject ?? [:]
        } catch {
            throw error
        }
    }
    
    typealias SerializedObject = [String: Any]
}
