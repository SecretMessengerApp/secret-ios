

import Foundation

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
//import AppCenterDistribute
//import WireSystem
import UIKit

@objc
extension AppDelegate {
    
    func setupAppCenter(completion: @escaping () -> Void) {
        let shouldUseAppCenter = AutomationHelper.sharedHelper.useAppCenter || Bundle.useAppCenter
        
        if !shouldUseAppCenter  {
            completion()
            return
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "kBITExcludeApplicationSupportFromBackup") //check
        let appCenterTrackingEnabled = !TrackingManager.shared.disableCrashAndAnalyticsSharing || true
        
        if shouldUseAppCenter {
            MSCrashes.setDelegate(self)
//            MSDistribute.setDelegate(self)
            MSAppCenter.start()
            MSAppCenter.setLogLevel(.info)
            
            // This method must only be used after Services have been started.
            MSAppCenter.setTrackingEnabled(appCenterTrackingEnabled)
        }
        
        if appCenterTrackingEnabled &&
            MSCrashes.hasCrashedInLastSession() &&
            MSCrashes.timeIntervalCrashInLastSessionOccurred ?? 0 < TimeInterval(5) {
            zmLog.error("AppCenterIntegration: START Waiting for the crash log upload...")
            self.appCenterInitCompletion = completion
            self.perform(#selector(crashReportUploadDone), with: nil, afterDelay: 5)
        } else {
            completion()
        }
    }
    
    @objc
    private func crashReportUploadDone() {
        
        zmLog.error("AppCenterIntegration: finished or timed out sending the crash report")
        
        if appCenterInitCompletion != nil {
            appCenterInitCompletion?()
            zmLog.error("AppCenterIntegration: END Waiting for the crash log upload...")
            appCenterInitCompletion = nil
        }
        
    }
    
    @objc
    func updateAppCenterUserInfo() {
        guard let account = SessionManager.shared?.accountManager.selectedAccount else { return }
        MSAppCenter.setUserId(account.userIdentifier.transportString())
    }
}

extension AppDelegate: MSCrashesDelegate {
    
    public func crashes(_ crashes: MSCrashes!, shouldProcessErrorReport errorReport: MSErrorReport!) -> Bool {
        return !TrackingManager.shared.disableCrashAndAnalyticsSharing
    }
    
    public func crashes(_ crashes: MSCrashes!, didSucceedSending errorReport: MSErrorReport!) {
        crashReportUploadDone()
    }
    
}
