
import Foundation

extension FloatingPoint {
    func equal(to other: Self, e: Self) -> Bool {
        return abs(self - other) <= e
    }
}
