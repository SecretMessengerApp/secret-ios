
import UIKit

class KingGridLayout: UICollectionViewFlowLayout {
    enum SizeDimension {
        case auto
        case fractionalWidth(ratio: CGFloat)
        case absolute(constant: CGFloat)
    }
    
    private let withDimension: SizeDimension
    private let heightDimension: SizeDimension
    
    init(widthDimension: SizeDimension, heightDimension: SizeDimension) {
        self.withDimension = widthDimension
        self.heightDimension = heightDimension
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var cols: Int = 3
    var rows: Int = 3
    var space: CGFloat = 16
    
    override func prepare() {
        super.prepare()
        
        var itemWidth: CGFloat = 0.0
        switch withDimension {
        case .auto:
            itemWidth = calculateItemWidth()
        case .absolute(let constant):
            itemWidth = constant
        default:
            fatalError("Invalid size dimension")
        }
        
        var itemHeight: CGFloat = 0.0
        switch heightDimension {
        case .absolute(let constant):
            itemHeight = constant
        case .fractionalWidth(let ratio):
            itemHeight = itemWidth * ratio
        default:
            itemHeight = calculateItemHeight()
        }
        
        self.minimumLineSpacing = space
        
        self.itemSize = CGSize(width: itemWidth, height: itemHeight)
    }
    
    func calculateItemWidth() -> CGFloat {
        guard let collectionView = self.collectionView else { return 0.0 }
        
        let availableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
        let itemWidth = (availableWidth - CGFloat(cols - 1) * space) / CGFloat(cols)
        return itemWidth
    }
    
    func calculateItemHeight() -> CGFloat {
        guard let collectionView = self.collectionView else { return 0.0 }
        
        let availableHeight = collectionView.bounds.inset(by: collectionView.layoutMargins).height
        let itemHeight = (availableHeight - CGFloat(rows - 1) * space) / CGFloat(rows)
        return itemHeight
    }
}
