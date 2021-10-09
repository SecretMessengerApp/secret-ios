
import Foundation
import UIKit

///TODO: remove public after MockUser is convert to Swift
public final class ImageCache<T : AnyObject> {
    var cache: NSCache<NSString, T> = NSCache()
    var processingQueue = DispatchQueue(label: "ImageCacheQueue", qos: .background, attributes: [.concurrent])
    var dispatchGroup: DispatchGroup = DispatchGroup()
}

extension UIImage {
    public static var defaultUserImageCache: ImageCache<UIImage> = ImageCache()
}

final class MediaAssetCache {
    static var defaultImageCache = ImageCache<AnyObject>()
}
