
import Foundation

/// A wrapper type to provide hashable capabilities for abstract types.

final class HashBox<Type: NSObjectProtocol>: Hashable {

    let value: Type

    init(value: Type) {
        self.value = value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(value.hash)
    }

    static func == (lhs: HashBox<Type>, rhs: HashBox<Type>) -> Bool {
        return lhs.value.isEqual(rhs.value)
    }

}
