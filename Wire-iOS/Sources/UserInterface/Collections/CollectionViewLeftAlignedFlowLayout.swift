

import Foundation

// NB: This class assumes that the elements in one section are of the same size.
final class CollectionViewLeftAlignedFlowLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.width != self.collectionView?.bounds.size.width
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let oldAttributes: [UICollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: rect) else {
            return .none
        }
        
        var newAttributes: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
        let maxCellWidth = self.collectionView!.bounds.size.width - self.sectionInset.left - self.sectionInset.right
        
        for attributes: UICollectionViewLayoutAttributes in oldAttributes {
            
            guard attributes.representedElementCategory == .cell else {
                newAttributes.append(attributes)

                continue
            }
            
            let totalElementsInSection = self.collectionView!.numberOfItems(inSection: attributes.indexPath.section)
            let sectionHasLessElementsThanWidth = totalElementsInSection == 1

            if sectionHasLessElementsThanWidth {
                let cellIsFullWidth = attributes.frame.size.width.equal(to: maxCellWidth, e: 1)
                let cellIsNotLeftAligned = attributes.frame.origin.x != self.sectionInset.left
                if !cellIsFullWidth && cellIsNotLeftAligned {
                    let inset = (maxCellWidth - CGFloat(totalElementsInSection) * attributes.frame.size.width) / 2
                    
                    var newLeftAlignedFrame: CGRect = attributes.frame
                    newLeftAlignedFrame.origin.x = newLeftAlignedFrame.origin.x - inset
                    attributes.frame = newLeftAlignedFrame
                }
            }
            
            newAttributes.append(attributes)
        }
        return newAttributes
    }
}
