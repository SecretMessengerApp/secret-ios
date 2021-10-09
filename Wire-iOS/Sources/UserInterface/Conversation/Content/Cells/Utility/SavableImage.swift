

import Photos

protocol PhotoLibraryProtocol {
    func performChanges(_ changeBlock: @escaping () -> Swift.Void, completionHandler: ((Bool, Error?) -> Swift.Void)?)

    func register(_ observer: PHPhotoLibraryChangeObserver)
    func unregisterChangeObserver(_ observer: PHPhotoLibraryChangeObserver)
}

extension PHPhotoLibrary: PhotoLibraryProtocol {}

protocol AssetChangeRequestProtocol: class {
    @discardableResult static func creationRequestForAsset(from image: UIImage) -> Self
    @discardableResult static func creationRequestForAssetFromImage(atFileURL fileURL: URL) -> Self?
}

protocol AssetCreationRequestProtocol: class {
    static func forAsset() -> Self
    func addResource(with type: PHAssetResourceType,
                     data: Data,
                     options: PHAssetResourceCreationOptions?)
}

extension PHAssetChangeRequest: AssetChangeRequestProtocol {}
extension PHAssetCreationRequest: AssetCreationRequestProtocol {}

private let log = ZMSLog(tag: "SavableImage")

final class SavableImage: NSObject {
    
    enum Source {
        case gif(URL)
        case image(Data)
    }
    
    /// Protocols used to inject mock photo services in tests
    var photoLibrary: PhotoLibraryProtocol = PHPhotoLibrary.shared()
    var assetChangeRequestType: AssetChangeRequestProtocol.Type = PHAssetChangeRequest.self
    var assetCreationRequestType: AssetCreationRequestProtocol.Type = PHAssetCreationRequest.self
    var applicationType: ApplicationProtocol.Type = UIApplication.self

    typealias ImageSaveCompletion = (Bool) -> Void

    private var writeInProgess = false
    private let imageData: Data
    private let isGIF: Bool

    init(data: Data, isGIF: Bool) {
        self.isGIF = isGIF
        imageData = data
        super.init()
    }
    
    private static  func storeGIF(_ data: Data) -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory() + "\(UUID().uuidString).gif")
        
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            log.error("error writing image data to \(url): \(error)")
        }
        
        return url
    }
    
    // SavableImage instances get created when image cells etc are being created and
    // we don't want to write data to disk when we didn't start a save operation, yet.
    private func createSource() -> Source {
        return isGIF ? .gif(SavableImage.storeGIF(imageData)) : .image(imageData)
    }
    
    public func saveToLibrary(withCompletion completion: ImageSaveCompletion? = .none) {
        guard !writeInProgess else { return }
        writeInProgess = true
        let source = createSource()
        
        let cleanup: (Bool) -> Void = { [source] success in
            if case .gif(let url) = source {
                try? FileManager.default.removeItem(at: url)
            }

            completion?(success)
        }

        applicationType.wr_requestOrWarnAboutPhotoLibraryAccess { granted in
            guard granted else { return cleanup(false) }
            
            self.photoLibrary.performChanges(papply(self.saveImage, source)) { success, error in
                DispatchQueue.main.async {
                    self.writeInProgess = false
                    error.apply(self.warnAboutError)
                    cleanup(success)
                }
            }
        }
    }

    // Has to be called from inside a `photoLibrary.performChanges` block
    private func saveImage(using source: Source) {
        switch source {
        case .gif(let url):
            _ = assetChangeRequestType.creationRequestForAssetFromImage(atFileURL: url)
        case .image(let data):
            assetCreationRequestType.forAsset().addResource(with: .photo, data: data, options: PHAssetResourceCreationOptions())
        }
    }

    private func warnAboutError(_ error: Error) {
        log.error("error saving image: \(error)")

        let alert = UIAlertController(
            title: "library.alert.permission_warning.title".localized,
            message: (error as NSError).localizedDescription,
            alertAction: .ok(style: .cancel)
        )

        AppDelegate.shared.notificationsWindow?.rootViewController?.present(alert, animated: true)
    }

}
