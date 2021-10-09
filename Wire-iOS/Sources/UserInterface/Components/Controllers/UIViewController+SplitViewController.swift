
import Foundation
import UIKit

extension UIViewController {
    
    var wr_splitViewController: SplitViewController? {
        var possibleSplit: UIViewController? = self

        repeat {
            if let splitViewController = possibleSplit as? SplitViewController {
                return splitViewController
            }

            possibleSplit = possibleSplit?.parent
        } while possibleSplit != nil

        return nil
    }
}
