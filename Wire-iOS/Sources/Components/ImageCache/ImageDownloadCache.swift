
import Foundation

enum ImageDownloadCacheError: Error, Equatable {
    case invalidResponse
    case invalidResponseCode(Int)
}

/**
 * An object that fetches and caches remote images.
 */

class ImageDownloadCache {

    /// The session that performs network requests.
    private let session: DataTaskSession

    /// The operation queue used for decoding images.
    private let imageDecodingQueue = OperationQueue()

    // MARK: - Initialization

    /**
     * Creates the cache for downloading images.
     *
     * - parameter session: The network session to use to download the images.
     */

    init(session: DataTaskSession) {
        self.session = session
    }

    /**
     * A shared image cache.
     *
     * It holds up to 100MB of images in memory, and up to 200MB on disk. It keeps images in the cache for
     * 2 hours, unless the URL specifies a different value.
     */

    static let shared: ImageDownloadCache = {
        return ImageDownloadCache(session: URLSession.shared)
    }()

    // MARK: - Image Fetching

    /**
     * Requests to get the image at the specified URL.
     *
     * Once the data was received from the server, the image will be decoded in the
     * background, and passed to the main thread through the completion handler.
     *
     * - parameter url: The URL of the image to download.
     * - parameter completionHandler: The block of code that will be executed on the
     * main thread with the retrieved image.
     * - parameter image: The image downloaded from the specified URL, or `nil` if no
     * image was available at this URL.
     */

    func fetchImage(at url: URL, completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {

        let resultHandler: (UIImage?, Error?) -> Void = { image, error in
            OperationQueue.main.addOperation {
                completionHandler(image, error)
            }
        }

        let downloadTask = session.makeDataTask(with: url) { data, response, error in

            if let error = error {
                resultHandler(nil, error)
                return
            }

            guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {
                resultHandler(nil, ImageDownloadCacheError.invalidResponse)
                return
            }

            guard let responseData = data else {
                resultHandler(nil, ImageDownloadCacheError.invalidResponse)
                return
            }

            guard (200 ..< 300).contains(responseCode) else {
                resultHandler(nil, ImageDownloadCacheError.invalidResponseCode(responseCode))
                return
            }

            self.decodeImage(with: responseData) {
                resultHandler($0, nil)
            }

        }

        downloadTask.resume()

    }

    /**
     * Schedules an attempt to decode the image from the given data.
     */

    private func decodeImage(with data: Data, resultHandler: @escaping (UIImage?) -> Void) {

        let decodingOperation = DecodeImageOperation(imageData: data)

        decodingOperation.completionBlock = {
            resultHandler(decodingOperation.decodedImage)
        }

        imageDecodingQueue.addOperation(decodingOperation)

    }

}
