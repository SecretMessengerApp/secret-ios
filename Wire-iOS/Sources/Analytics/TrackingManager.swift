
import Foundation
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import avs

class TrackingManager: NSObject, TrackingInterface {
    private let flowManagerObserver: NSObjectProtocol
    
    private override init() {
        AVSFlowManager.getInstance()?.setEnableMetrics(!ExtensionSettings.shared.disableCrashAndAnalyticsSharing)
        
        flowManagerObserver = NotificationCenter.default.addObserver(forName: FlowManager.AVSFlowManagerCreatedNotification, object: nil, queue: OperationQueue.main, using: { _ in
            AVSFlowManager.getInstance()?.setEnableMetrics(!ExtensionSettings.shared.disableCrashAndAnalyticsSharing)
        })
    }
    
    static let shared = TrackingManager()

    var disableCrashAndAnalyticsSharing: Bool {
        set {
            Analytics.shared().isOptedOut = newValue
            AVSFlowManager.getInstance()?.setEnableMetrics(!newValue)
            updateAppCenterStateIfNeeded(oldState: disableCrashAndAnalyticsSharing, newValue)
            ExtensionSettings.shared.disableCrashAndAnalyticsSharing = newValue
        }
        
        get {
            return ExtensionSettings.shared.disableCrashAndAnalyticsSharing
        }
    }

    private func updateAppCenterStateIfNeeded(oldState: Bool, _ newState: Bool) {
        switch (oldState, newState) {
        case (true, false):
            MSAppCenter.setEnabled(true)
            MSAppCenter.start()
            updateUserInfo()
        case (false, true):
            MSAppCenter.setEnabled(false)
        default:
            return
        }
    }
    
    private func updateUserInfo() {
        guard let account = SessionManager.shared?.accountManager.selectedAccount else { return }
        MSAppCenter.setUserId(account.userIdentifier.transportString())
    }
}
