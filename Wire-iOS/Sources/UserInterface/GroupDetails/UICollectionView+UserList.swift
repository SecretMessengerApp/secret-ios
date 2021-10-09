
import Foundation

fileprivate extension UICollectionViewFlowLayout {
    convenience init(forUserList: ()) {
        self.init()
        scrollDirection = .vertical
        minimumInteritemSpacing = 12
        minimumLineSpacing = 0
    }
}

extension UICollectionView {
    convenience init(forUserList: ()) {
        self.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout(forUserList: ()))
        backgroundColor = UIColor.dynamic(scheme: .background)
        allowsMultipleSelection = false
        keyboardDismissMode = .onDrag
        bounces = true
        alwaysBounceVertical = true
        contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 32, right: 0)
        accessibilityIdentifier = "group_details.list"
    }
}
