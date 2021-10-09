
import Foundation

public protocol Reusable {
    static var reuseIdentifier: String { get }
    var reuseIdentifier: String? { get }
}

public extension Reusable {
    static var reuseIdentifier: String {
        guard let `class` = self as? AnyClass else { return "\(self)" }
        return NSStringFromClass(`class`)
    }
    
    var reuseIdentifier: String? {
        return type(of: self).reuseIdentifier
    }
}

extension UITableViewCell: Reusable {}
extension UICollectionReusableView: Reusable {}
