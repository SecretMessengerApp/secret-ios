//
//  GridLayout2.swift
//  Layout

import UIKit

class GridLayout: UICollectionViewLayout {
    var columns = 4 {
        didSet {
            if oldValue != columns {
                invalidateLayout()
            }
        }
    }
    
    var rows = 2 {
        didSet {
            if oldValue != rows {
                invalidateLayout()
            }
        }
    }
    
    var cellSpacing = CGFloat(30)
    
    private var contentBounds = CGRect.zero
    private var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        cachedAttributes.removeAll()
        
        let availableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
        let availableHeight = collectionView.bounds.inset(by: collectionView.layoutMargins).height
        
        let itemWidth = (availableWidth - cellSpacing * CGFloat(columns - 1)) / CGFloat(columns)
        let itemHeight = (availableHeight - cellSpacing * CGFloat(rows - 1)) / CGFloat(rows)
        
        let itemsCount = collectionView.numberOfItems(inSection: 0)
        let itemsPerPage = columns * rows
        let pages = ceil(lhs: itemsCount, rhs: itemsPerPage)
        
        let contentSize = CGSize(width: collectionView.bounds.size.width * CGFloat(pages),
                                 height: collectionView.bounds.size.height)
        contentBounds = CGRect(origin: .zero, size: contentSize)
        
        for i in 0..<itemsCount {
            let page = i / itemsPerPage
            let startX =  collectionView.bounds.size.width * CGFloat(page)
            
            let col = i % columns
            let row = (i % itemsPerPage) / columns
            
            let x = startX + collectionView.layoutMargins.left + (cellSpacing + itemWidth) * CGFloat(col)
            let y = collectionView.layoutMargins.top + (cellSpacing + itemHeight) * CGFloat(row)
            
            let frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
            attributes.frame = frame
            cachedAttributes.append(attributes)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    // MARK: LayoutAttributesForItem
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes
    }
}

func ceil(lhs: Int, rhs: Int) -> Int {
    guard lhs >= 0 && rhs > 0 else {
        fatalError("Invalid parameters")
    }
    return lhs / rhs + ((lhs % rhs == 0) ? 0 : 1)
}
