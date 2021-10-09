
import Photos

protocol ImageManagerProtocol {
    func cancelImageRequest(_ requestID: PHImageRequestID)

    @discardableResult
    func requestImage(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID

    @discardableResult
    func requestImageData(for asset: PHAsset, options: PHImageRequestOptions?, resultHandler: @escaping (Data?, String?, UIImage.Orientation, [AnyHashable : Any]?) -> Void) -> PHImageRequestID

    @discardableResult
    func requestExportSession(forVideo asset: PHAsset, options: PHVideoRequestOptions?, exportPreset: String, resultHandler: @escaping (AVAssetExportSession?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID

    static var defaultInstance: ImageManagerProtocol { get }
}

extension PHImageManager: ImageManagerProtocol {
    static var defaultInstance: ImageManagerProtocol {
        return PHImageManager.default()
    }
}
