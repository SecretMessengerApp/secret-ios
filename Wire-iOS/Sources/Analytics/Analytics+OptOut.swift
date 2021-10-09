
import Foundation

extension Analytics {
    
    /// Opt the user out of sending analytics data
    var isOptedOut: Bool {
        get {
            guard let provider = provider else { return true }
            return provider.isOptedOut
        }

        set {
            if newValue && (provider?.isOptedOut ?? false) {
                return
            }

            if newValue {
                tagEvent("settings.opted_out_tracking")

                provider?.flush() {
                    self.provider?.isOptedOut = newValue
                    self.provider = nil
                }
            } else {
                provider = AnalyticsProviderFactory.shared.analyticsProvider()
                setTeam(ZMUser.selfUser()?.team)
                tagEvent("settings.opted_in_tracking")
            }
        }
    }
}
