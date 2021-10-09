
import Foundation
import UIKit

extension CGSize {
    /// returns the longest length among width and height
    var longestLength: CGFloat {
        return width > height ? width : height
    }

    var shortestLength: CGFloat {
        return width > height ? height : width
    }
}

extension CGFloat {
    enum Image {
        /// Maximum image size that would show in a UIImageView.
        /// Tested on iPhone 5s and found that the image size limitation is ~5000px
        static public let maxSupportedLength: CGFloat = 5000
    }
}

extension UIImage {
    @objc
    func downsizedImage() -> UIImage? {
        return downsized()
    }


    /// downsize an image to the size which the longer side length equal to maxLength
    ///
    /// - Parameter maxLength: The maxLength of the resized image
    /// - Returns: an image with longer side length equal to maxLength, return nil if fail to scale the image
    func downsized(maxLength: CGFloat = CGFloat.Image.maxSupportedLength) -> UIImage? {
        let longestLength = size.longestLength

        guard longestLength > maxLength else { return self }

        let ratio = maxLength / longestLength / UIScreen.main.scale
        return imageScaled(with: ratio)
    }

    /// downsize an image to the size which the shorter side length equal to shorterSizeLength
    ///
    /// - Parameter shorterSizeLength: The target shorter size of the resized image
    /// - Returns: an image with shorter side length equal to shorterSizeLength, return nil if fail to scale the image
    func downsized(shorterSizeLength: CGFloat) -> UIImage? {
        let shortestLength = size.shortestLength

        guard shortestLength > shorterSizeLength else { return self }

        let ratio = shorterSizeLength / shortestLength / UIScreen.main.scale
        return imageScaled(with: ratio)
    }
}
