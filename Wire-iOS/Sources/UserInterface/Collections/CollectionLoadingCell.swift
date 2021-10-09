
import Foundation
import Cartography

 final class CollectionLoadingCell: UICollectionViewCell {
    let loadingView = UIActivityIndicatorView(style: .gray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(self.loadingView)
        self.contentView.clipsToBounds = true
        
        self.loadingView.startAnimating()
        self.loadingView.hidesWhenStopped = false
        
        constrain(self.contentView, self.loadingView) { contentView, loadingView in
            loadingView.center == contentView.center
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var containerWidth: CGFloat = 320
    var collapsed: Bool = false {
        didSet {
            self.loadingView.isHidden = self.collapsed
        }
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        var newFrame = layoutAttributes.frame
        newFrame.size.height = 24 + (self.collapsed ? 0 : 64)
        newFrame.size.width = self.containerWidth
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}
