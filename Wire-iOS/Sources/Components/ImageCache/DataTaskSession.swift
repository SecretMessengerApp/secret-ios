
import Foundation

// MARK: Protocols

/**
 * A network session task that downloads data.
 */

protocol DataTask: class {

    /// The unique identifier of the task within its session.
    var taskIdentifier: Int { get }

    /// The current request performed by the session.
    var currentRequest: URLRequest? { get }

    /// The response of the session, available if it completed without error.
    var response: URLResponse? { get }

    /// Starts the task.
    func resume()

}

/**
 * An object that schedules and manages data tasks.
 */

protocol DataTaskSession: class {

    /// Creates a data request task for the given URL.
    func makeDataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> DataTask

}

// MARK: - Conformance

extension URLSessionDataTask: DataTask {}

extension URLSession: DataTaskSession {

    func makeDataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> DataTask {
        return dataTask(with: url, completionHandler: completionHandler)
    }

}
