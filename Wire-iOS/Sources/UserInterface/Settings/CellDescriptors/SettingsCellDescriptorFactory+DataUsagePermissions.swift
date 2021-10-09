
import Foundation

extension SettingsCellDescriptorFactory {
    func dataUsagePermissionsGroup() -> SettingsCellDescriptorType {
        var items: [SettingsSectionDescriptor] = []

        let sendAnonymousData = SettingsPropertyToggleCellDescriptor(settingsProperty: self.settingsPropertyFactory.property(.disableCrashAndAnalyticsSharing), inverse: true)
        let sendAnonymousDataSection = SettingsSectionDescriptor(cellDescriptors: [sendAnonymousData], footer: "self.settings.privacy_analytics_menu.description.title".localized)

        let receiveNewsAndOffersData = SettingsPropertyToggleCellDescriptor(settingsProperty: self.settingsPropertyFactory.property(.receiveNewsAndOffers))
        let receiveNewsAndOffersSection = SettingsSectionDescriptor(cellDescriptors: [receiveNewsAndOffersData], footer: "self.settings.receiveNews_and_offers.description.title".localized)

       
        items.append(contentsOf: [sendAnonymousDataSection/*, receiveNewsAndOffersSection*/])

        return SettingsGroupCellDescriptor(
            items: items,
            title: "self.settings.account.data_usage_permissions.title".localized
        )
    }
}
