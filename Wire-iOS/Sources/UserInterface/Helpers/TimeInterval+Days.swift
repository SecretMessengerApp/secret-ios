
import Foundation

extension Calendar {

    static func secondsInDays(_ numberOfDays: UInt) -> TimeInterval {
        return Double(numberOfDays) * 24 * 3600
    }

}
