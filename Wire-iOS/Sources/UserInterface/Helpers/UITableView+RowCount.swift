
import UIKit

extension UITableView {
    var numberOfTotalRows: Int {
        var sum = 0
        for section in 0..<numberOfSections {
            sum += numberOfRows(inSection: section)
        }
        return sum
    }
}
