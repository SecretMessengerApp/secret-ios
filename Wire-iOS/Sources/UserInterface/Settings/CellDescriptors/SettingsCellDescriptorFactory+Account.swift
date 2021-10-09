

import Foundation


extension ZMUser {
    var hasValidEmail: Bool {
        guard let email = self.emailAddress,
                !email.isEmpty else {
            return false
        }
        return true
    }
}

extension SettingsCellDescriptorFactory {

    func accountGroup() -> SettingsCellDescriptorType {
        var sections: [SettingsSectionDescriptorType] = [infoSection()]

        if userRightInterfaceType.selfUserIsPermitted(to: .editAccentColor) &&
           userRightInterfaceType.selfUserIsPermitted(to: .editProfilePicture) {
            sections.append(appearanceSection())
        }

        sections.append(privacySection())

        #if !DATA_COLLECTION_DISABLED
            sections.append(personalInformationSection())
        #endif

        sections.append(conversationsSection())
        
        if let user = ZMUser.selfUser(), !user.usesCompanyLogin {
            sections.append(actionsSection())
        }
        
        //sections.append(signOutSection())

        return SettingsGroupCellDescriptor(items: sections, title: "self.settings.account_section".localized, icon: .settingAccount)
    }

    // MARK: - Sections

    func infoSection() -> SettingsSectionDescriptorType {
        var cellDescriptors: [SettingsCellDescriptorType] = []
        cellDescriptors = [nameElement(enabled: userRightInterfaceType.selfUserIsPermitted(to: .editName)),
                           handleElement(enabled: userRightInterfaceType.selfUserIsPermitted(to: .editHandle))]
        
        if let user = ZMUser.selfUser(), !user.usesCompanyLogin {
            if !ZMUser.selfUser().hasTeam || !(ZMUser.selfUser().phoneNumber?.isEmpty ?? true),
               let phoneElement = phoneElement(enabled: userRightInterfaceType.selfUserIsPermitted(to: .editPhone)){
                cellDescriptors.append(phoneElement)
            }
            
            cellDescriptors.append(emailElement(enabled: userRightInterfaceType.selfUserIsPermitted(to: .editEmail)))
            cellDescriptors.append(qrcodeElement())
        }
        return SettingsSectionDescriptor(
            cellDescriptors: cellDescriptors,
            header: "self.settings.account_details_group.info.title".localized,
            footer: .none
        )
    }

    func appearanceSection() -> SettingsSectionDescriptorType {
        return SettingsSectionDescriptor(
            cellDescriptors: [pictureElement(), colorElement()],
            header: "self.settings.account_appearance_group.title".localized
        )
    }
    
    func privacySection() -> SettingsSectionDescriptorType {
        return SettingsSectionDescriptor(
            cellDescriptors: [readReceiptsEnabledElement()],
            header: "self.settings.privacy_section_group.title".localized,
            footer: "self.settings.privacy_section_group.subtitle".localized
        )
    }

    func personalInformationSection() -> SettingsSectionDescriptorType {
        return SettingsSectionDescriptor(
            cellDescriptors: [dateUsagePermissionsElement()],
            header: "self.settings.account_personal_information_group.title".localized
        )
    }

    func conversationsSection() -> SettingsSectionDescriptorType {
        return SettingsSectionDescriptor(
            cellDescriptors: [backUpElement()],
            header: "self.settings.conversations.title".localized
        )
    }

    func actionsSection() -> SettingsSectionDescriptorType {
        let cellDescriptors = [resetPasswordElement(), signOutElement()]
//        if let selfUser = self.settingsPropertyFactory.selfUser, !selfUser.isTeamMember {
//            cellDescriptors.append(deleteAccountButtonElement())
//        }
        
        return SettingsSectionDescriptor(
            cellDescriptors: cellDescriptors,
            header: "self.settings.account_details.actions.title".localized,
            footer: .none
        )
    }

    func signOutSection() -> SettingsSectionDescriptorType {
        return SettingsSectionDescriptor(cellDescriptors: [signOutElement()], header: .none, footer: .none)
    }

    // MARK: - Elements
    private func textValueCellDescriptor(propertyName: SettingsPropertyName, enabled: Bool = true) -> SettingsPropertyTextValueCellDescriptor {
        var settingsProperty = settingsPropertyFactory.property(propertyName)
        settingsProperty.enabled = enabled

        return SettingsPropertyTextValueCellDescriptor(settingsProperty: settingsProperty)
    }


    func nameElement(enabled: Bool = true) -> SettingsPropertyTextValueCellDescriptor {
        return textValueCellDescriptor(propertyName: .profileName, enabled: enabled)
    }

    func emailElement(enabled: Bool = true) -> SettingsCellDescriptorType {
        if enabled {
            return SettingsExternalScreenCellDescriptor(
                title: "self.settings.account_section.email.title".localized,
                isDestructive: false,
                presentationStyle: .navigation,
                presentationAction: { () -> (UIViewController?) in
                    return ChangeEmailViewController(user: ZMUser.selfUser())
                },
                previewGenerator: { _ in
                    if let email = ZMUser.selfUser().emailAddress, !email.isEmpty {
                        return SettingsCellPreview.text(email)
                    } else {
                        return SettingsCellPreview.text("self.add_email_password".localized)
                    }
                },
                accessoryViewMode: .alwaysHide
            )
        } else {
            return textValueCellDescriptor(propertyName: .email, enabled: enabled)
        }
    }

    func phoneElement(enabled: Bool = true) -> SettingsCellDescriptorType? {
        if enabled {
            return SettingsExternalScreenCellDescriptor(
                title: "self.settings.account_section.phone.title".localized,
                isDestructive: false,
                presentationStyle: .navigation,
                presentationAction: {
                    return ChangePhoneViewController()
                },
                previewGenerator: { _ in
                    if let phoneNumber = ZMUser.selfUser().phoneNumber, !phoneNumber.isEmpty {
                        return SettingsCellPreview.text(phoneNumber)
                    } else {
                        return SettingsCellPreview.text("self.add_phone_number".localized)
                    }
            },
                accessoryViewMode: .alwaysHide
            )
        } else {
            if let phoneNumber = ZMUser.selfUser().phoneNumber, !phoneNumber.isEmpty {
                return textValueCellDescriptor(propertyName: .phone, enabled: enabled)
            } else {
                return nil
            }
        }
    }

    func handleElement(enabled: Bool = true) -> SettingsCellDescriptorType {
        if enabled {
            let presentation: () -> ChangeHandleViewController = {
                return ChangeHandleViewController()
            }

            if nil != ZMUser.selfUser().handle {
                let preview: PreviewGeneratorType = { _ in
                    guard let handleDisplayString = ZMUser.selfUser()?.handleDisplayString else { return .none }
                    return .text(handleDisplayString)
                }
                return SettingsExternalScreenCellDescriptor(
                    title: "self.settings.account_section.handle.title".localized,
                    isDestructive: false,
                    presentationStyle: .navigation,
                    presentationAction: presentation,
                    previewGenerator: preview,
                    accessoryViewMode: .alwaysHide
                )
            }

            return SettingsExternalScreenCellDescriptor(
                title: "self.settings.account_section.add_handle.title".localized,
                presentationAction: presentation
            )
        } else {
            return textValueCellDescriptor(propertyName: .handle, enabled: enabled)
        }
    }

    func pictureElement() -> SettingsCellDescriptorType {
        let previewGenerator: PreviewGeneratorType = { _ in
            guard let image = ZMUser.selfUser().imageSmallProfileData.flatMap(UIImage.init) else { return .none }
            return .image(image, true)
        }
        return SettingsExternalScreenCellDescriptor(
            title: "self.settings.account_picture_group.picture".localized,
            isDestructive: false,
            presentationStyle: .modal,
            presentationAction: { () -> (UIViewController?) in
                ProfileSelfPictureViewController(context: .selfUser(ZMUser.selfUser()?.previewImageData))
            },
            previewGenerator: previewGenerator
        )
    }

    func colorElement() -> SettingsCellDescriptorType {
        return SettingsExternalScreenCellDescriptor(
            title: "self.settings.account_picture_group.color".localized,
            isDestructive: false,
            presentationStyle: .modal,
            presentationAction: AccentColorPickerController.init,
            previewGenerator: { _ in .color(ZMUser.selfUser().accentColor) }
        )
    }
    
    func readReceiptsEnabledElement() -> SettingsCellDescriptorType {
        return SettingsPropertyToggleCellDescriptor(settingsProperty: self.settingsPropertyFactory.property(.readReceiptsEnabled),
                                                    inverse: false,
                                                    identifier: "ReadReceiptsSwitch")
    }

    func backUpElement() -> SettingsCellDescriptorType {
        return SettingsExternalScreenCellDescriptor(
            title: "self.settings.history_backup.title".localized,
            isDestructive: false,
            presentationStyle: .navigation,
            presentationAction: {
                if ZMUser.selfUser().hasValidEmail || ZMUser.selfUser()!.usesCompanyLogin {
                    return BackupViewController.init(backupSource: SessionManager.shared!)
                }
                else {
                    let alert = UIAlertController(
                        title: "self.settings.history_backup.set_email.title".localized,
                        message: "self.settings.history_backup.set_email.message".localized,
                        preferredStyle: .alert
                    )
                    let actionCancel = UIAlertAction(title: "general.ok".localized, style: .cancel, handler: nil)
                    alert.addAction(actionCancel)

                    guard let controller = UIApplication.shared.topmostViewController(onlyFullScreen: false) else { return nil }

                    controller.present(alert, animated: true)
                    return nil
                }
        }
        )
    }

    func dateUsagePermissionsElement() -> SettingsCellDescriptorType {
        return dataUsagePermissionsGroup()
    }

    func resetPasswordElement() -> SettingsCellDescriptorType {
        let resetPasswordTitle = "self.settings.password_reset_menu.title".localized
        return SettingsExternalScreenCellDescriptor(title: resetPasswordTitle, isDestructive: false, presentationStyle: .modal, presentationAction: { 
            return BrowserViewController(url: URL.wr_passwordReset.appendingLocaleParameter)
        }, previewGenerator: .none)
    }

    func deleteAccountButtonElement() -> SettingsCellDescriptorType {
        let presentationAction: () -> UIViewController = {
            let alert = UIAlertController(
                title: "self.settings.account_details.delete_account.alert.title".localized,
                message: "self.settings.account_details.delete_account.alert.message".localized,
                preferredStyle: .alert
            )
            let actionCancel = UIAlertAction(title: "general.cancel".localized, style: .cancel, handler: nil)
            alert.addAction(actionCancel)
            let actionDelete = UIAlertAction(title: "general.ok".localized, style: .destructive) { _ in
                ZMUserSession.shared()?.enqueueChanges {
                    ZMUserSession.shared()?.initiateUserDeletion()
                }
            }
            alert.addAction(actionDelete)
            return alert
        }

        return SettingsExternalScreenCellDescriptor(
            title: "self.settings.account_details.delete_account.title".localized,
            isDestructive: true,
            presentationStyle: .modal,
            presentationAction: presentationAction
        )
    }

    func signOutElement() -> SettingsCellDescriptorType {
        return SettingsSignOutCellDescriptor()
    }

}
