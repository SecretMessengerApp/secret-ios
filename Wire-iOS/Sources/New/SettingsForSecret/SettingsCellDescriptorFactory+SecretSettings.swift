//
//  SettingsCellDescriptorFactory+SecretSettings.swift
//  Wire-iOS
//

import Foundation

extension SettingsCellDescriptorFactory {
    

    func accountManagerCell() -> SettingsCellDescriptorType {
        return SettingsExternalScreenCellDescriptor(title: "self.settings.account_manager.title".localized,
                                                    isDestructive: false,
                                                    presentationStyle: PresentationStyle.navigation,
                                                    identifier: nil,
                                                    presentationAction: { () -> (UIViewController?) in
                                                        return AccountManagerController()
        },
                                                    previewGenerator: nil,
                                                    icon: .settingAccountManager,
                                                    accessoryViewMode: .alwaysShow)
    }
    
    // Scan Login
    func scanLoginCell() -> SettingsCellDescriptorType {
        return SettingsExternalScreenCellDescriptor(
            title: "self.settings.account_section.qrCode.title".localized,
            isDestructive: false,
            presentationStyle: .navigation,
            identifier: nil,
            presentationAction: {
                return ScanForLoginViewController()
        },
            previewGenerator: nil,
            icon: .settingScanLoginWeb,
            accessoryViewMode: .alwaysShow
        )
    }
    

    func praiseCell() -> SettingsCellDescriptorType {
        return SettingsExternalScreenCellDescriptor(title: "self.settings.praise.title".localized,
                                                    isDestructive: false,
                                                    presentationStyle: PresentationStyle.navigation,
                                                    identifier: nil,
                                                    presentationAction: { () -> (UIViewController?) in
                                                        
                                                        UIApplication.shared.keyWindow?.endEditing(true)
                                                        let praiseStr = "itms-apps://itunes.apple.com/cn/app/id1374264186?mt=8&action=write-review"
                                                        if let praiseURL = URL(string: praiseStr) {
                                                            UIApplication.shared.open(praiseURL)
                                                        }
                                                        return nil
        },
                                                    previewGenerator: nil,
                                                    icon: .star,
                                                    accessoryViewMode: .alwaysShow)
    }
    
    ///
    /// - Returns:
    func qrcodeElement() -> SettingsCellDescriptorType {
        SettingsExternalScreenCellDescriptor(
            title: "self.settings.account_section.myQRCode.title".localized,
            isDestructive: false,
            presentationStyle: PresentationStyle.navigation,
            identifier: nil,
            presentationAction: { QRCodeDisplayViewController(context: .mine) },
            previewGenerator: { _ -> SettingsCellPreview in
                .image(UIImage(named: "QRcode")!, false)
            }
        )
    }
    
    func contactGroup() -> SettingsControllerGeneratorType & SettingsInternalGroupCellDescriptorType {
        let email = "secret@secret.chat"
        let contactCell = SettingsStaticTextCellDescriptor(text: email)
        contactCell.onSelectAction = {
            UIPasteboard.general.string = email
            HUD.success("hud.copied".localized)
        }
        let contactSection = SettingsSectionDescriptor(cellDescriptors: [contactCell])
        
        return SettingsGroupCellDescriptor(items: [contactSection], title: "self.settings.contact.title".localized, style: .grouped, previewGenerator: .none, icon: .settingContact)
    }
}
