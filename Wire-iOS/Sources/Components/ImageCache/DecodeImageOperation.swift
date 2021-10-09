
import UIKit

/**
 * An operation that decodes a UIImage in the background, from its raw data.
 *
 * You can get the decoded image by accessing the `imageData` property once the
 * operation has completed.
 */

class DecodeImageOperation: Operation {

    /// The initial data of the image.
    let imageData: Data

    /// The image that was decoded from the initial data.
    private(set) var decodedImage: UIImage?

    /// Creates the operation from the raw image data.
    init(imageData: Data) {
        self.imageData = imageData
    }

    // MARK: - Decoding

    override func main() {

        guard !isCancelled else {
            return
        }

        decodedImage = UIImage(data: imageData)?.decoded
    }

}
