
import Foundation
import UIKit

extension CGSize {
    func minZoom(imageSize: CGSize?) -> CGFloat {
        guard let imageSize = imageSize else { return 1 }
        guard imageSize != .zero else { return 1 }
        guard self != .zero else { return 1 }

        var minZoom = min(self.width / imageSize.width, self.height / imageSize.height)

        if minZoom > 1 {
            minZoom = 1
        }

        return minZoom
    }

    /// returns true if both with and height are longer than otherSize
    ///
    /// - Parameter otherSize: other CGSize to compare
    /// - Returns: true if both with and height are longer than otherSize
    func contains(_ otherSize: CGSize) -> Bool {
        return otherSize.width < width &&
               otherSize.height < height
    }
}
