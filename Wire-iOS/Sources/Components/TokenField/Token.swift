
import Foundation
import UIKit

final class Token<T: NSObjectProtocol>: Hashable {

    let representedObject: HashBox<T>

    let title: String

    // if title render is longer than this length, it is trimmed with "..."
    var maxTitleWidth: CGFloat = 0

    init(title: String,
         representedObject: T) {
        self.title = title
        self.representedObject = HashBox(value: representedObject)

        maxTitleWidth = .greatestFiniteMagnitude
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(representedObject)
    }

    static func == (lhs: Token<T>, rhs: Token<T>) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
