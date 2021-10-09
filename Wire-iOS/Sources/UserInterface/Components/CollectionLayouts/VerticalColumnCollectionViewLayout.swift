
import UIKit

protocol VerticalColumnCollectionViewLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, sizeOfItemAt indexPath: IndexPath) -> CGSize
}

/**
 * A collection view layout that displays its contents within multiple columns.
 */

class VerticalColumnCollectionViewLayout: UICollectionViewLayout {

    // MARK: - Configuration

    /// The object providing size information to the layout.
    weak var delegate: VerticalColumnCollectionViewLayoutDelegate?

    /// The number of columns to use to organize the content.
    var numberOfColumns: Int = 1 {
        didSet { invalidateLayout() }
    }

    /// The spacing between columns.
    var interColumnSpacing: CGFloat = 10 {
        didSet { invalidateLayout() }
    }

    /// The spacing between two items in the same column.
    var interItemSpacing: CGFloat = 10 {
        didSet { invalidateLayout() }
    }

    // MARK: - Size

    /// The width of the collection container.
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = self.collectionView else {
            return 0
        }

        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    /// The height of the collection container.
    fileprivate var contentHeight: CGFloat {
        guard let collectionView = self.collectionView else {
            return 0
        }

        let baseHeight = positioning?.contentHeight ?? 0
        let insets = collectionView.contentInset
        return baseHeight - (insets.top + insets.bottom)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    // MARK: - Layout

    /// The current positioning of the items.
    fileprivate var positioning: VerticalColumnPositioning?

    /// The current positioning context.
    fileprivate var positioningContext: VerticalColumnPositioningContext {
        return VerticalColumnPositioningContext(contentWidth: contentWidth,
                                                numberOfColumns: numberOfColumns,
                                                interItemSpacing: interItemSpacing,
                                                interColumnSpacing: interColumnSpacing)
    }

    override func prepare() {
        guard self.positioning == nil, let collectionView = collectionView, let delegate = self.delegate else {
            return
        }

        var positioning = VerticalColumnPositioning(context: self.positioningContext)

        for row in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            let size = delegate.collectionView(collectionView, sizeOfItemAt: indexPath)
            positioning.insertItem(ofSize: size, at: indexPath)
        }

        self.positioning = positioning
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return positioning?.rows.filter { $0.frame.height > 0 && $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let position = positioning?.rows[indexPath.item] else {
            return nil
        }

        guard position.frame.height > 0 else {
            return nil
        }

        return position
    }

    // MARK: - Invalidation

    override func invalidateLayout() {
        positioning = nil
        super.invalidateLayout()
    }

}
