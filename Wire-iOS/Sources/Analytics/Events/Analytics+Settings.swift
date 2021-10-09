

import Foundation

private let settingsChangeEvent = "settings.changed_value"
private let settingsChangeEventPropertyName = "property"
private let settingsChangeEventPropertyValue = "new_value"

extension Analytics {
    
    internal func tagSettingsChanged(for propertyName: SettingsPropertyName, to value: SettingsPropertyValue) {
        guard let value = value.value(),
                propertyName != SettingsPropertyName.disableCrashAndAnalyticsSharing else {
            return
        }
        let attributes = [settingsChangeEventPropertyName: propertyName,
                          settingsChangeEventPropertyValue: value]
        tagEvent(settingsChangeEvent, attributes: attributes)
    }
    
    func tagOpenManageTeamURL() {
        self.tagEvent("settings.opened_manage_team")
    }
}
