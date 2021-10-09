
import Foundation
import WireSystem

private let zmLog = ZMSLog(tag: "Analytics")

fileprivate let ZMEnableConsoleLog = "ZMEnableAnalyticsLog"

final class AnalyticsProviderFactory: NSObject {
    static let shared = AnalyticsProviderFactory(userDefaults: .shared()!)
    static let ZMConsoleAnalyticsArgumentKey = "-ConsoleAnalytics"

    var useConsoleAnalytics: Bool = false

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
  
    public func analyticsProvider() -> AnalyticsProvider? {
        if self.useConsoleAnalytics || UserDefaults.standard.bool(forKey: ZMEnableConsoleLog) {
            zmLog.info("Creating analyticsProvider: AnalyticsConsoleProvider")
            return AnalyticsConsoleProvider()
        }
        else if AutomationHelper.sharedHelper.useAnalytics {
            // Create & return valid provider, when available.
            return nil
        }
        else {
            zmLog.info("Creating analyticsProvider: no provider")
            return nil
        }
    }
}

