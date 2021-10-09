
import Foundation

extension ZClientViewController {
    
    func createDataUsagePermissionDialogIfNeeded() -> UIAlertController? {
        guard !AutomationHelper.sharedHelper.skipFirstLoginAlerts else { return nil }
        
        guard !dataCollectionDisabled else { return nil }
        
        // If the usage dialog was already displayed in this run, do not show it again
        guard !dataUsagePermissionDialogDisplayed else { return nil }
        
        // Check if the app state requires showing the alert
        guard needToShowDataUsagePermissionDialog else { return nil }
        
        // If the user registers, show the alert.
        guard isComingFromRegistration else { return nil }
        
        let alertController = UIAlertController(title: "conversation_list.data_usage_permission_alert.title".localized, message: "conversation_list.data_usage_permission_alert.message".localized, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "conversation_list.data_usage_permission_alert.disagree".localized, style: .cancel, handler: { (_) in
            TrackingManager.shared.disableCrashAndAnalyticsSharing = true
        }))
        
        alertController.addAction(UIAlertAction(title: "conversation_list.data_usage_permission_alert.agree".localized, style: .default, handler: { (_) in
            TrackingManager.shared.disableCrashAndAnalyticsSharing = false
        }))
        
        alertController.applyTheme()
        
        return alertController
    }
    
    func showDataUsagePermissionDialogIfNeeded() {
        
        guard let alertController = createDataUsagePermissionDialogIfNeeded() else { return }

        present(alertController, animated: true)

        dataUsagePermissionDialogDisplayed = true
    }
    
    private var dataCollectionDisabled: Bool {
        #if DATA_COLLECTION_DISABLED
        return true
        #else
        return false
        #endif
    }

}
