

import UIKit

// MARK: Cell Registration

extension NSObject {
    static var zm_reuseIdentifier: String {
        return NSStringFromClass(self) + "_ReuseIdentifier"
    }
}

extension UITableViewCell {
    static func register(in tableView: UITableView) {
        tableView.register(self, forCellReuseIdentifier: zm_reuseIdentifier)
    }
}

extension UICollectionViewCell {
    static func register(in collectionView: UICollectionView) {
        collectionView.register(self, forCellWithReuseIdentifier: zm_reuseIdentifier)
    }
}

// MARK: - Cell Dequeuing

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(ofType cellType: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.zm_reuseIdentifier, for: indexPath) as! T
    }
}

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(ofType cellType: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: T.zm_reuseIdentifier, for: indexPath) as! T
    }
}
