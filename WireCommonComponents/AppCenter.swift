
import Foundation
import AppCenter
import AppCenterCrashes
//import AppCenterDistribute
import AppCenterAnalytics

public extension MSAppCenter {
    
    static func setTrackingEnabled(_ enabled: Bool) {
        MSAnalytics.setEnabled(enabled)
//        MSDistribute.setEnabled(enabled)
        MSCrashes.setEnabled(enabled)
    }
    
    static func start() {
        MSAppCenter.start(Bundle.appCenterAppId, withServices: [MSCrashes.self, MSAnalytics.self])
    }
}

public extension MSCrashes {
    
    static var timeIntervalCrashInLastSessionOccurred: TimeInterval? {
        guard let lastSessionCrashReport = lastSessionCrashReport() else { return nil }
        return lastSessionCrashReport.appErrorTime.timeIntervalSince(lastSessionCrashReport.appStartTime)
    }
}

public extension Bundle {
    
    static var appCenterAppId: String? {
        return Bundle.appMainBundle.infoForKey("USE_APP_CENTER_KEY")?.replacingOccurrences(of: "appcenter-", with: "")
    }
    
    static var useAppCenter: Bool {
        return Bundle.appMainBundle.infoForKey("UseAppCenter") == "1"
    }
}
