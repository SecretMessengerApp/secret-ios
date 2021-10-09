
import Foundation
import MobileCoreServices
import FLAnimatedImage

extension UIPasteboard {

    func pasteboardType(forMediaAsset mediaAsset: MediaAsset) -> String {
        if mediaAsset.isGIF {
            return kUTTypeGIF as String
        } else if mediaAsset.isTransparent {
            return kUTTypePNG as String
        } else {
            return kUTTypeJPEG as String
        }
    }

    ///TODO: get/set
    func mediaAsset() -> MediaAsset? {
        if contains(pasteboardTypes: [kUTTypeGIF as String]) {
            let data: Data? = self.data(forPasteboardType: kUTTypeGIF as String)
            return FLAnimatedImage(animatedGIFData: data)
        } else if contains(pasteboardTypes: [kUTTypePNG as String]) {
            let data: Data? = self.data(forPasteboardType: kUTTypePNG as String)
            if let aData = data {
                return UIImage(data: aData)
            }
            return nil
        } else if hasImages {
            return image
        }
        return nil
    }

    func setMediaAsset(_ image: MediaAsset?) {
        guard let image = image,
              let data = image.imageData else { return }

        UIPasteboard.general.setData(data, forPasteboardType: pasteboardType(forMediaAsset: image))
    }
}
