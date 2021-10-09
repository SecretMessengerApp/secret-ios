
import Foundation
import UIKit

extension UIImage: MediaAsset {
    var imageData: Data? {
        if isTransparent {
            return pngData()
        } else {
            return jpegData(compressionQuality: 1.0)
        }
    }

    var isGIF: Bool {
        false
    }

    var isTransparent: Bool {
        guard let alpha: CGImageAlphaInfo = self.cgImage?.alphaInfo else { return false }

        switch alpha {
        case .first, .last, .premultipliedFirst, .premultipliedLast, .alphaOnly:
            return true
        default:
            return false
        }
    }
}
