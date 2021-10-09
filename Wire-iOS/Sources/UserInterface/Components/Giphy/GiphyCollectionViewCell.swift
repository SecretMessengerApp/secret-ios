
import UIKit
import Cartography
import Ziphy
import FLAnimatedImage

final class GiphyCollectionViewCell: UICollectionViewCell {

    static let CellIdentifier = "GiphyCollectionViewCell"

    let imageView = FLAnimatedImageView()
    var ziph: Ziph?
    var representation: ZiphyAnimatedImage?

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)

        constrain(self.contentView, self.imageView) { contentView, imageView in
            imageView.edges == contentView.edges
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        self.imageView.animatedImage = nil
        self.ziph = nil
        self.representation = nil
        self.backgroundColor = nil
    }

}
