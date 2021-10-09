
import Foundation

fileprivate var ciContext = CIContext(options: nil)

public var defaultUserImageCache: ImageCache<UIImage> = ImageCache()


typealias ProfileImageFetchableUser = UserType & ProfileImageFetchable

protocol ProfileImageFetchable {
    func fetchProfileImage(session: ZMUserSessionInterface, cache: ImageCache<UIImage>, sizeLimit: Int?, desaturate: Bool, completion: @escaping (_ image: UIImage?, _ cacheHit: Bool) -> Void ) -> Void
}

extension ProfileImageFetchable where Self: UserType {
    private func cacheKey(for size: ProfileImageSize, sizeLimit: Int?, desaturate: Bool) -> String? {

        guard let baseKey = (size == .preview ? smallProfileImageCacheKey : mediumProfileImageCacheKey) else {
            return nil
        }

        var derivedKey = baseKey

        if desaturate {
            derivedKey = "\(derivedKey)_desaturated"
        }

        if let sizeLimit = sizeLimit {
            derivedKey = "\(derivedKey)_\(sizeLimit)"
        }

        return derivedKey
    }

    func fetchProfileImage(session: ZMUserSessionInterface, cache: ImageCache<UIImage> = defaultUserImageCache, sizeLimit: Int? = nil, desaturate: Bool = false, completion: @escaping (_ image: UIImage?, _ cacheHit: Bool) -> Void ) -> Void {

        let screenScale = UIScreen.main.scale
        let previewSizeLimit: CGFloat = 280
        let size: ProfileImageSize
        if let sizeLimit = sizeLimit {
            size = CGFloat(sizeLimit) * screenScale < previewSizeLimit ? .preview : .complete
        } else {
            size = .complete
        }

        guard let cacheKey = cacheKey(for: size, sizeLimit: sizeLimit, desaturate: desaturate) as NSString? else {
            return completion(nil, false)
        }

        if let image = cache.cache.object(forKey: cacheKey) {
            return completion(image, true)
        }

        switch size {
        case .preview:
            self.requestPreviewProfileImage()
        default:
            self.requestCompleteProfileImage()
        }

        imageData(for: size, queue: cache.processingQueue) { (imageData) in
            guard let imageData = imageData else {
                return DispatchQueue.main.async {
                    completion(nil, false)
                }
            }

            var image: UIImage?
            if let sizeLimit = sizeLimit {
                image = UIImage(from: imageData, withMaxSize: CGFloat(sizeLimit) * screenScale)
            } else {
                image = UIImage(data: imageData)?.decoded
            }

            if desaturate {
                image = image?.desaturatedImage(with: ciContext, saturation: 0)
            }

            if let image = image {
                cache.cache.setObject(image, forKey: cacheKey)
            }

            DispatchQueue.main.async {
                completion(image, false)
            }
        }
    }
}

extension ZMUser: ProfileImageFetchable {}

extension ZMSearchUser: ProfileImageFetchable {}

extension ConversationBGPMemberModel: ProfileImageFetchable {}
