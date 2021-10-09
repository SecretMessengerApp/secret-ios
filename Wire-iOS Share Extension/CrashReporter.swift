

import WireCommonComponents
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes


/// Flag to determine if the App Center SDK has already been initialized
private var didSetupAppCenter = false


/// Helper to setup crash reporting in the share extension
final class CrashReporter {
    
    static func setupAppCenterIfNeeded() {
        guard !didSetupAppCenter, appCenterEnabled, let _ = Bundle.appCenterAppId else { return }
        didSetupAppCenter = true
        
        UserDefaults.standard.set(true, forKey: "kBITExcludeApplicationSupportFromBackup")
        
        
        //Enable after securing app extensions from App Center
        MSAppCenter.setTrackingEnabled(!ExtensionSettings.shared.disableCrashAndAnalyticsSharing)
        MSAppCenter.configure(withAppSecret: Bundle.appCenterAppId)
        MSAppCenter.start()
        
    }
    
    private static var appCenterEnabled: Bool {
        let configUseAppCenter = Bundle.useAppCenter // The preprocessor macro USE_APP_CENTER (from the .xcconfig files)
        let automationUseAppCenter = AutomationHelper.sharedHelper.useAppCenter // Command line argument used by automation
        let settingsDisableCrashAndAnalyticsSharing = ExtensionSettings.shared.disableCrashAndAnalyticsSharing // User consent
        
        return (automationUseAppCenter || (!automationUseAppCenter && configUseAppCenter))
                && !settingsDisableCrashAndAnalyticsSharing
    }
}

