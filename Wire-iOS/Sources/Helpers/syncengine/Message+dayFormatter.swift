
import Foundation

extension Message {
    @objc static func dayFormatter(date: Date) -> DateFormatter {
        return date.olderThanOneWeekdateFormatter
    }
}

