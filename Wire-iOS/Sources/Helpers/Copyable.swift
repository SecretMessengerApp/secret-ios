
import Foundation

public protocol Copyable {
    init(instance: Self)
}

public extension Copyable {
    func copyInstance() -> Self {
        return Self.init(instance: self)
    }
}
