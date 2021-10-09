
import Foundation
import FormatterKit

// Creating and configuring date formatters is insanely expensive.
// This is why there’s a bunch of statically configured ones here that are reused.
public class WRDateFormatter {
    static let NSTimeIntervalOneHour = 3600.0
    static let DayMonthYearUnits = Set<Calendar.Component>([.day, .month, .year])
    static let WeekMonthYearUnits = Set<Calendar.Component>([.weekOfMonth, .month, .year])

    /// use this to format clock times, so they are correctly formatted to 12/24 hours according to locale
    static var clockTimeFormatter: DateFormatter {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        timeFormatter.locale = Language.locale
        return timeFormatter
    }

    static var timeIntervalFormatter: TTTTimeIntervalFormatter {
        let timeFormatter = TTTTimeIntervalFormatter()
        timeFormatter.presentTimeIntervalMargin = 60
        timeFormatter.usesApproximateQualifier = false
        timeFormatter.usesIdiomaticDeicticExpressions = true
        return timeFormatter
    }

    static var todayYesterdayFormatter: DateFormatter {
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Language.locale
        timeFormatter.timeStyle = .short
        timeFormatter.doesRelativeDateFormatting = true
        return timeFormatter
    }

    static var thisWeekFormatter: DateFormatter {
        let locale = Language.locale
        let timeFormatter = DateFormatter()
        let formatString: String? = DateFormatter.dateFormat(fromTemplate: "EEEE", options: 0, locale: locale)
        timeFormatter.dateFormat = formatString ?? ""
        timeFormatter.locale = locale
        return timeFormatter
    }

    public static var thisYearFormatter: DateFormatter {
        let locale = Language.locale
        let formatString = DateFormatter.dateFormat(fromTemplate: "EEEEdMMMM", options: 0, locale: locale)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        dateFormatter.locale = locale
        return dateFormatter
    }

    public static var otherYearFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Language.locale
        dateFormatter.dateStyle = .full
        return dateFormatter
    }
}

extension Date {
    public var olderThanOneWeekdateFormatter: DateFormatter {
        let today = Date()

        let isThisYear = Calendar.current.isDate(self, equalTo: today, toGranularity: .year)

        if isThisYear {
            return WRDateFormatter.thisYearFormatter
        } else {
            return WRDateFormatter.otherYearFormatter
        }
    }

    public var formattedDate: String {
        let gregorian = Calendar(identifier: .gregorian)
        // Today's date
        let today = Date()
        let todayDateComponents: DateComponents? = gregorian.dateComponents(WRDateFormatter.DayMonthYearUnits, from: today)
        // Yesterday
        var componentsToSubtract = DateComponents()
        componentsToSubtract.day = -1

        let yesterday = gregorian.date(byAdding: componentsToSubtract, to: today)
        let yesterdayComponents: DateComponents? = gregorian.dateComponents(WRDateFormatter.DayMonthYearUnits, from: yesterday!)
        // This week
        let thisWeekComponents: DateComponents? = gregorian.dateComponents(WRDateFormatter.WeekMonthYearUnits, from: today)
        // Received date
        let dateComponents: DateComponents? = gregorian.dateComponents(WRDateFormatter.DayMonthYearUnits, from: self)
        let weekComponents: DateComponents? = gregorian.dateComponents(WRDateFormatter.WeekMonthYearUnits, from: self)

        let intervalSinceDate: TimeInterval = -timeIntervalSinceNow
        let isToday: Bool = todayDateComponents == dateComponents
        let isYesterday: Bool = yesterdayComponents == dateComponents
        let isThisWeek: Bool = thisWeekComponents == weekComponents
        var dateString = String()

        // Date is within the last hour
        if (intervalSinceDate < WRDateFormatter.NSTimeIntervalOneHour) {
            if #available(iOS 13.0, *) {
                dateString = timeIntervalFormatter.localizedString(fromTimeInterval: -intervalSinceDate)
            } else {
                dateString = WRDateFormatter.timeIntervalFormatter.string(forTimeInterval: -intervalSinceDate)
            }
        }
            // Date is from today or yesterday
        else if isToday || isYesterday {
            let dateStyle: DateFormatter.Style = isToday ? .none : .medium
            WRDateFormatter.todayYesterdayFormatter.dateStyle = dateStyle
            dateString = WRDateFormatter.todayYesterdayFormatter.string(from: self)
        } else if isThisWeek {
            dateString = "\(WRDateFormatter.thisWeekFormatter.string(from: self)) \(WRDateFormatter.clockTimeFormatter.string(from: self))"
        } else {
            let dateFormatter = olderThanOneWeekdateFormatter
            dateString = "\(dateFormatter.string(from: self)) \(WRDateFormatter.clockTimeFormatter.string(from: self))"
        }

        return dateString
    }
    
    @available(iOS 13.0, *)
    private var timeIntervalFormatter: RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Language.locale
        formatter.unitsStyle = .full
        return formatter
    }
}

