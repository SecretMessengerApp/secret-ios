
import UIKit

/**
 * A view that displays a list of cells that can be accessed by their index.
 */
protocol IndexedListView {
    /// The number of sections in the list.
    var numberOfSections: Int { get }
    /// The number of cells in the specified section of the list.
    func numberOfCells(inSection section: Int) -> Int
}

extension IndexedListView {

    /**
     * Checks whether the indexed list view contains an item at the given index path.
     * - parameter indexPath: The index path to check.
     */

    func containsCell(at indexPath: IndexPath) -> Bool {
        if indexPath.section < 0 || indexPath.section >= numberOfSections {
            return false
        }
        if indexPath.row < 0 || indexPath.row >= numberOfCells(inSection: indexPath.section) {
            return false
        }
        return true
    }

}

extension UITableView: IndexedListView {
    func numberOfCells(inSection section: Int) -> Int {
        return numberOfRows(inSection: section)
    }
}

extension UICollectionView: IndexedListView {
    func numberOfCells(inSection section: Int) -> Int {
        return numberOfItems(inSection: section)
    }
}
