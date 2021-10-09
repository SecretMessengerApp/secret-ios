
import Foundation

fileprivate extension UICollectionViewFlowLayout {
    convenience init(forGroupedSections: ()) {
        self.init()
        scrollDirection = .vertical
        minimumInteritemSpacing = 12
        minimumLineSpacing = 0
    }
}

extension UICollectionView {
    
    convenience init(forGroupedSections: ()) {
        self.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout(forGroupedSections: ()))
        backgroundColor = .clear
        allowsMultipleSelection = false
        keyboardDismissMode = .onDrag
        bounces = true
        alwaysBounceVertical = true
        contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 32, right: 0)
    }
}
