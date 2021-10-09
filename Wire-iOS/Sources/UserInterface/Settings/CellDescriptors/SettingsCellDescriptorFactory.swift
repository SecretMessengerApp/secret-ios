

import Foundation
import SafariServices
import avs
import LocalAuthentication

class SettingsCellDescriptorFactory {
    static let settingsDevicesCellIdentifier: String = "devices"
    static let settingsSecurityCellIdentifier: String = "Security"
    static let settingsThemeCellIdentifier: String = "theme"

    let settingsPropertyFactory: SettingsPropertyFactory
    let userRightInterfaceType: UserRightInterface.Type
    let user: ZMUser?
    let conversation: ZMConversation?
    var groupConversation: ZMConversation?
    class DismissStepDelegate: NSObject {
        var strongCapture: DismissStepDelegate?
        // TODO: Remove
        @objc func didCompleteFormStep(_ viewController: UIViewController!) {
            NotificationCenter.default.post(name: NSNotification.Name.DismissSettings, object: nil)
            self.strongCapture = nil
        }
    }
    
    init(settingsPropertyFactory: SettingsPropertyFactory,
         userRightInterfaceType: UserRightInterface.Type = UserRight.self) {
        self.settingsPropertyFactory = settingsPropertyFactory
        self.userRightInterfaceType = userRightInterfaceType
        self.user = settingsPropertyFactory.selfUser as? ZMUser
        self.conversation = settingsPropertyFactory.conversation
    }
    
    func rootGroup() -> SettingsControllerGeneratorType & SettingsInternalGroupCellDescriptorType {
        var postElements: [SettingsCellDescriptorType] = []
        var safetyElements: [SettingsCellDescriptorType] = []
        var rootElements: [SettingsCellDescriptorType] = []

        if ZMUser.selfUser().canManageTeam {
            rootElements.append(self.manageTeamCell())
        }
        
        postElements.append(self.scanLoginCell())
        safetyElements.append(self.accountManagerCell())
        rootElements.append(self.settingsGroup())
        rootElements.append(self.contactGroup())
//        #if MULTIPLE_ACCOUNTS_DISABLED
//            // We skip "add account" cell
//        #else
//            rootElements.append(self.addAccountOrTeamCell())
//        #endif
        let postSection = SettingsSectionDescriptor(cellDescriptors: postElements)
        let safetySection = SettingsSectionDescriptor(cellDescriptors: safetyElements)
        let topSection = SettingsSectionDescriptor(cellDescriptors: rootElements)

        return SettingsGroupCellDescriptor(items: [postSection, safetySection, topSection], title: "self.profile".localized, style: .grouped)
    }
    
    func manageTeamCell() -> SettingsCellDescriptorType {
        return SettingsExternalScreenCellDescriptor(title: "self.settings.manage_team.title".localized,
                                                    isDestructive: false,
                                                    presentationStyle: PresentationStyle.modal,
                                                    identifier: nil,
                                                    presentationAction: { () -> (UIViewController?) in
                                                        Analytics.shared().tagOpenManageTeamURL()
                                                        return BrowserViewController(url: URL.manageTeam(source: .settings))
                                                    },
                                                    previewGenerator: nil,
                                                    icon: .team,
                                                    accessoryViewMode: .alwaysHide)
    }
    
    func addAccountOrTeamCell() -> SettingsCellDescriptorType {
        
        let presentationAction: () -> UIViewController? = {
            
            if SessionManager.shared?.accountManager.accounts.count < SessionManager.maxNumberAccounts {
                SessionManager.shared?.addAccount()
            }
            else {
                if let controller = UIApplication.shared.topmostViewController(onlyFullScreen: false) {
                    let alert = UIAlertController(
                        title: "self.settings.add_account.error.title".localized,
                        message: "self.settings.add_account.error.message".localized,
                        alertAction: .ok(style: .cancel)
                    )
                    controller.present(alert, animated: true, completion: nil)
                }
            }
            
            return nil
        }
        
        return SettingsExternalScreenCellDescriptor(title: "self.settings.add_team_or_account.title".localized,
                                                    isDestructive: false,
                                                    presentationStyle: PresentationStyle.modal,
                                                    identifier: nil,
                                                    presentationAction: presentationAction,
                                                    previewGenerator: nil,
                                                    icon: .plus,
                                                    accessoryViewMode: .alwaysHide)
    }
    
    func settingsGroup() -> SettingsControllerGeneratorType & SettingsInternalGroupCellDescriptorType {
        var topLevelElements = [
            languageElement(),
            accountGroup(),
            devicesCell(),
            backUpCell(),
            optionsGroup(),
            advancedGroup(),
            /*self.helpSection(),*/
            aboutSection(),
            privacySettingSection()
        ]
        if #available(iOS 13.0, *) {
            topLevelElements.insert(darkModeItem(), at: 0)
        }
        
        let topSection = SettingsSectionDescriptor(cellDescriptors: topLevelElements)
        
        return SettingsGroupCellDescriptor(items: [topSection], title: "self.settings".localized, style: .grouped, previewGenerator: .none, icon: .settingSetting)
    }

    func languageElement() -> SettingsCellDescriptorType {
        SettingsExternalScreenCellDescriptor(
            title: "self.settings.language.title".localized,
            isDestructive: false,
            presentationStyle: .navigation,
            presentationAction: { LanguageViewController(style: .grouped) },
            previewGenerator: { _ -> SettingsCellPreview in
                SettingsCellPreview.text(Language.current.title)
            },
            icon: .settingLanguage
        )
    }
    
    func devicesCell() -> SettingsCellDescriptorType {
        return SettingsExternalScreenCellDescriptor(title: "self.settings.privacy_analytics_menu.devices.title".localized,
            isDestructive: false,
            presentationStyle: PresentationStyle.navigation,
            identifier: type(of: self).settingsDevicesCellIdentifier,
            presentationAction: { () -> (UIViewController?) in
                return ClientListViewController(clientsList: .none,
                                                credentials: .none,
                                                detailedView: true,
                                                variant: .light)
            },
            previewGenerator: { _ -> SettingsCellPreview in
                return SettingsCellPreview.badge(ZMUser.selfUser().clients.count)
            },
           icon: .settingDevice)
    }
    
    func backUpCell() -> SettingsCellDescriptorType {
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
                
        },
            icon: .settingBackup)
    }

    func soundGroupForSetting(_ settingsProperty: SettingsProperty, title: String, customSounds: [ZMSound], defaultSound: ZMSound) -> SettingsCellDescriptorType {
        let items: [ZMSound] = [ZMSound.None, defaultSound] + customSounds
        let previewPlayer: SoundPreviewPlayer = SoundPreviewPlayer(mediaManager: AVSMediaManager.sharedInstance())
        
        let cells: [SettingsPropertySelectValueCellDescriptor] = items.map { item in
            let playSoundAction: SettingsPropertySelectValueCellDescriptor.SelectActionType = { cellDescriptor in
                
                switch settingsProperty.propertyName {
                case .callSoundName:
                    previewPlayer.playPreview(.ringingFromThemSound)
                case .pingSoundName:
                    previewPlayer.playPreview(.incomingKnockSound)
                case .messageSoundName:
                    previewPlayer.playPreview(.messageReceivedSound)
                default:
                    break
                }
            }
            
            let propertyValue = item == defaultSound ? SettingsPropertyValue.none : SettingsPropertyValue.string(value: item.rawValue)
            return SettingsPropertySelectValueCellDescriptor(settingsProperty: settingsProperty, value: propertyValue, title: item.descriptionLocalizationKey.localized, identifier: .none, selectAction: playSoundAction)
        }
        
        let section = SettingsSectionDescriptor(cellDescriptors: cells.map { $0 as SettingsCellDescriptorType }, header: "self.settings.sound_menu.ringtones.title".localized)
        
        let previewGenerator: PreviewGeneratorType = { cellDescriptor in
            let value = settingsProperty.value()
            
            if let stringValue = value.value() as? String,
                let enumValue = ZMSound(rawValue: stringValue) {
                return .text(enumValue.descriptionLocalizationKey.localized)
            }
            else {
                return .text(defaultSound.descriptionLocalizationKey.localized)
            }
        }
        
        return SettingsGroupCellDescriptor(items: [section], title: title, identifier: .none, previewGenerator: previewGenerator)
    }

    func advancedGroup() -> SettingsCellDescriptorType {
        var items: [SettingsSectionDescriptor] = []
        
        let troubleshootingSectionTitle = "self.settings.advanced.troubleshooting.title".localized
        let troubleshootingTitle = "self.settings.advanced.troubleshooting.submit_debug.title".localized
        let troubleshootingSectionSubtitle = "self.settings.advanced.troubleshooting.submit_debug.subtitle".localized
        let troubleshootingButton = SettingsExternalScreenCellDescriptor(title: troubleshootingTitle) { () -> (UIViewController?) in
            return SettingsTechnicalReportViewController()
        }
        
        let troubleshootingSection = SettingsSectionDescriptor(cellDescriptors: [troubleshootingButton], header: troubleshootingSectionTitle, footer: troubleshootingSectionSubtitle)
        
        let pushTitle = "self.settings.advanced.reset_push_token.title".localized
        let pushSectionSubtitle = "self.settings.advanced.reset_push_token.subtitle".localized
        
        let pushButton = SettingsExternalScreenCellDescriptor(title: pushTitle, isDestructive: false, presentationStyle: PresentationStyle.modal, presentationAction: { () -> (UIViewController?) in
            ZMUserSession.shared()?.validatePushToken()
            let alert = UIAlertController(title: "self.settings.advanced.reset_push_token_alert.title".localized, message: "self.settings.advanced.reset_push_token_alert.message".localized, preferredStyle: .alert)
            weak var weakAlert = alert;
            alert.addAction(UIAlertAction(title: "general.ok".localized, style: .default, handler: { (alertAction: UIAlertAction) -> Void in
                if let alert = weakAlert {
                    alert.dismiss(animated: true, completion: nil)
                }
            }));
            return alert
        })
        
        let pushSection = SettingsSectionDescriptor(cellDescriptors: [pushButton], header: .none, footer: pushSectionSubtitle)  { (_) -> (Bool) in
            return true
        }

//        let versionTitle =  "self.settings.advanced.version_technical_details.title".localized
//        let versionCell = SettingsButtonCellDescriptor(title: versionTitle, isDestructive: false) { _ in
//            let versionInfoViewController = VersionInfoViewController()
//            var superViewController = UIApplication.shared.keyWindow?.rootViewController
//            if let presentedViewController = superViewController?.presentedViewController {
//                superViewController = presentedViewController
//                versionInfoViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//                versionInfoViewController.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//            }
//            superViewController?.present(versionInfoViewController, animated: true, completion: .none)
//        }

//        let versionSection = SettingsSectionDescriptor(cellDescriptors: [versionCell])

        items.append(contentsOf: [troubleshootingSection, pushSection/*, versionSection*/])
        
        return SettingsGroupCellDescriptor(
            items: items,
            title: "self.settings.advanced.title".localized,
            icon: .settingAdvanced
        )
    }
    
    @available(iOS 13.0, *)
    func darkModeItem() -> SettingsCellDescriptorType {
        SettingsExternalScreenCellDescriptor(
            title: "self.settings.dark_mode.title".localized,
            isDestructive: false,
            presentationStyle: .navigation,
            identifier: type(of: self).settingsThemeCellIdentifier,
            presentationAction: { DarkModeSettingViewController(style: .grouped) },
            previewGenerator: { _ -> SettingsCellPreview in
                SettingsCellPreview.text(AppTheme.current.description)
            },
            icon: .settingDarkMode
        )
    }
    
    func requestNumber(_ callback: @escaping (Int)->()) {
        guard let controllerToPresentOver = UIApplication.shared.topmostViewController(onlyFullScreen: false) else { return }

        
        let controller = UIAlertController(
            title: "Enter count of messages",
            message: nil,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "general.ok".localized, style: .default) { [controller] _ in
            callback(Int(controller.textFields?.first?.text ?? "0")!)
        }
        
        controller.addTextField()
        
        controller.addAction(.cancel { })
        controller.addAction(okAction)
        controllerToPresentOver.present(controller, animated: true, completion: nil)
    }
    
    func appendMessagesInBatches(count: Int) {
        var left = count
        let step = 10_000
        
        repeat {
            let toAppendInThisStep = left < step ? left : step
            
            left = left - toAppendInThisStep
            
            appendMessages(count: toAppendInThisStep)
        }
        while(left > 0)
    }
    
    func appendMessages(count: Int) {
        let batchSize = 5_000
        
        var currentCount = count
        
        repeat {
            let thisBatchCount = currentCount > batchSize ? batchSize : currentCount

            appendMessagesToDatabase(count: thisBatchCount)
            
            currentCount = currentCount - thisBatchCount
        }
        while (currentCount > 0)
    }
    
    func appendMessagesToDatabase(count: Int) {
        let userSession = ZMUserSession.shared()!
        let conversation = ZMConversationList.conversations(inUserSession: userSession).firstObject! as! ZMConversation
        let conversationId = conversation.objectID
        
        let syncContext = userSession.syncManagedObjectContext!
        syncContext.performGroupedBlock {
            let syncConversation = try! syncContext.existingObject(with: conversationId) as! ZMConversation
            let messages: [ZMClientMessage] = (0...count).map { i in
                let nonce = UUID()
                let genericMessage = ZMGenericMessage.message(content: ZMText.text(with: "Debugging message \(i): Append many messages to the top conversation; Append many messages to the top conversation;"), nonce: nonce)
                let clientMessage = ZMClientMessage(nonce: nonce, managedObjectContext: syncContext)
                clientMessage.add(genericMessage.data())
                clientMessage.sender = ZMUser.selfUser(in: syncContext)
                
                clientMessage.expire()
                clientMessage.linkPreviewState = .done
                
                return clientMessage
            }
            syncConversation.mutableMessages.addObjects(from: messages)
            userSession.syncManagedObjectContext.saveOrRollback()
        }
    }
    
    func helpSection() -> SettingsCellDescriptorType {
        
        let supportButton = SettingsExternalScreenCellDescriptor(title: "self.help_center.support_website".localized, isDestructive: false, presentationStyle: .modal, presentationAction: { 
            return BrowserViewController(url: URL.wr_support.appendingLocaleParameter)
        }, previewGenerator: .none)
        
        let contactButton = SettingsExternalScreenCellDescriptor(title: "self.help_center.contact_support".localized, isDestructive: false, presentationStyle: .modal, presentationAction: { 
            return BrowserViewController(url: URL.wr_askSupport.appendingLocaleParameter)
        }, previewGenerator: .none)
        
        let helpSection = SettingsSectionDescriptor(cellDescriptors: [supportButton, contactButton])
        
        let reportButton = SettingsExternalScreenCellDescriptor(title: "self.report_abuse".localized, isDestructive: false, presentationStyle: .modal, presentationAction: { 
            return BrowserViewController(url: URL.wr_reportAbuse.appendingLocaleParameter)
        }, previewGenerator: .none)
        
        let reportSection = SettingsSectionDescriptor(cellDescriptors: [reportButton])
        
        return SettingsGroupCellDescriptor(items: [helpSection, reportSection], title: "self.help_center".localized, style: .grouped, identifier: .none, previewGenerator: .none, icon: .settingsSupport)
    }
    
    func aboutSection() -> SettingsCellDescriptorType {
        let websiteButton = SettingsExternalScreenCellDescriptor(title: "about.website.title".localized, isDestructive: false, presentationStyle: .modal, presentationAction: { return BrowserViewController(url: URL(string: "https://secret.chat")!.appendingLocaleParameter) }, accessoryViewMode: .alwaysShow)
        
        let tosButton = SettingsExternalScreenCellDescriptor(title: "about.tos.title".localized, isDestructive: false, presentationStyle: .modal, presentationAction: {
            let url = URL.wr_termsOfServicesURL(forTeamAccount: ZMUser.selfUser().hasTeam).appendingLocaleParameter
            return BrowserViewController(url: url)
        }, accessoryViewMode: .alwaysShow)

        let privacyPolicyButton = SettingsExternalScreenCellDescriptor(title: "about.privacy.title".localized, isDestructive: false, presentationStyle: .modal, presentationAction: {
            return BrowserViewController(url: URL.wr_privacyPolicy.appendingLocaleParameter)
        }, accessoryViewMode: .alwaysShow)
        
        let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? "Unknown"

        var currentYear = NSCalendar.current.component(.year, from: Date())
        if currentYear < 2014 {
            currentYear = 2014
        }

        let version = String(format: "Version %@ (%@)", shortVersion, buildNumber)
        let copyrightInfo = String(format: "about.copyright.title".localized, currentYear)

        let section = SettingsSectionDescriptor(
            cellDescriptors: [websiteButton, tosButton, privacyPolicyButton, licensesSection()],
            footer: "\n" + version + "\n" + copyrightInfo
        )
        
        return SettingsGroupCellDescriptor(
            items: [section],
            title: "self.about".localized,
            style: .grouped,
            identifier: .none,
            previewGenerator: .none,
            icon: .settingAbout
        )
    }

    func licensesSection() -> SettingsCellDescriptorType {
        guard let licenses = LicensesLoader.shared.loadLicenses() else {
            return webLicensesSection()
        }

        let childItems: [SettingsGroupCellDescriptor] = licenses.map { item in
           
//            let projectCell = SettingsExternalScreenCellDescriptor(title: "about.license.open_project_button".localized, isDestructive: false, presentationStyle: .modal, presentationAction: {
//                return BrowserViewController(url: item.projectURL)
//            }, previewGenerator: .none)
//            let detailsSection = SettingsSectionDescriptor(cellDescriptors: [projectCell], header: "about.license.project_header".localized, footer: nil)

            let licenseCell = SettingsStaticTextCellDescriptor(text: item.licenseText)
            let licenseSection = SettingsSectionDescriptor(cellDescriptors: [licenseCell], header: "about.license.license_header".localized, footer: nil)

            return SettingsGroupCellDescriptor(items: [/*detailsSection,*/ licenseSection], title: item.name, style: .grouped)
        }

        let licensesSection = SettingsSectionDescriptor(cellDescriptors: childItems)
        return SettingsGroupCellDescriptor(items: [licensesSection], title: "about.license.title".localized, style: .plain)

    }

    func webLicensesSection() -> SettingsCellDescriptorType {
        return SettingsExternalScreenCellDescriptor(title: "about.license.title".localized, isDestructive: false, presentationStyle: .modal, presentationAction: {
            let url = URL.wr_licenseInformation.appendingLocaleParameter
            return BrowserViewController(url: url)
        }, previewGenerator: .none)
    }
    
    func privacySettingSection() -> SettingsCellDescriptorType {
        var items: [SettingsSectionDescriptor] = []
        
        let blockUserTitle = "moment.privacy.setting.notsee".localized
        
        let lockApp = SettingsPropertyToggleCellDescriptor(settingsProperty: self.settingsPropertyFactory.property(.lockApp))
        lockApp.settingsProperty.enabled = !AppLock.rules.forceAppLock
        let section = SettingsSectionDescriptor(cellDescriptors: [lockApp],
                                                headerGenerator: { return nil },
                                                footerGenerator: { return SettingsCellDescriptorFactory.appLockSectionSubtitle },
                                                visibilityAction: { _ in return LAContext().canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil) })
        items.append(contentsOf: [section])
        
        return SettingsGroupCellDescriptor(
            items: items,
            title: "setting.privacy.setting.cell.title".localized,
            icon: .settingPrivacy
        )
    }
    
    private static var appLockSectionSubtitle: String {
        let timeout = TimeInterval(AppLock.rules.appLockTimeout)
        guard let amount = SettingsCellDescriptorFactory.appLockFormatter.string(from: timeout) else { return "" }
        let lockDescription = "self.settings.privacy_security.lock_app.subtitle.lock_description".localized(args: amount)
        let typeKey: String = {
            switch AuthenticationType.current {
            case .touchID: return "self.settings.privacy_security.lock_app.subtitle.touch_id"
            case .faceID: return "self.settings.privacy_security.lock_app.subtitle.face_id"
            default: return "self.settings.privacy_security.lock_app.subtitle.none"
            }
        }()
        
        return lockDescription + " " + typeKey.localized
    }
    
    // MARK: Actions
    
    /// Check if there is any unread conversation, if there is, show an alert with the name and ID of the conversation
    private static func findUnreadConversationContributingToBadgeCount(_ type: SettingsCellDescriptorType) {
        guard let userSession = ZMUserSession.shared() else { return }
        let predicate = ZMConversation.predicateForConversationConsideredUnread()!
        
        guard let controller = UIApplication.shared.topmostViewController(onlyFullScreen: false) else { return }
        let alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)

        let uiMOC = userSession.managedObjectContext
        let fetchRequest = NSFetchRequest<ZMConversation>(entityName: ZMConversation.entityName())
        let allConversations = uiMOC?.fetchOrAssert(request: fetchRequest)
        
        if let convo = allConversations?.first(where: { predicate.evaluate(with: $0) }) {
            alert.message = ["Found an unread conversation:",
                       "\(convo.displayName)",
                        "<\(convo.remoteIdentifier?.uuidString ?? "n/a")>"
                ].joined(separator: "\n")
            alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { _ in
                UIPasteboard.general.string = alert.message
            }))

        } else {
            alert.message = "No unread conversation"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller.present(alert, animated: false)
    }
    
    private static func recalculateBadgeCount(_ type: SettingsCellDescriptorType) {
        guard let userSession = ZMUserSession.shared() else { return }
        guard let controller = UIApplication.shared.topmostViewController(onlyFullScreen: false) else { return }
        
        var conversations: [ZMConversation]? = nil
        userSession.syncManagedObjectContext.performGroupedBlock {
            conversations = try? userSession.syncManagedObjectContext.fetch(NSFetchRequest<ZMConversation>(entityName: ZMConversation.entityName()))
            conversations?.forEach({ _ = $0.estimatedUnreadCount })
        }
        userSession.syncManagedObjectContext.dispatchGroup.wait(forInterval: 5)
        userSession.syncManagedObjectContext.performGroupedBlockAndWait {
            conversations = nil
            userSession.syncManagedObjectContext.saveOrRollback()
        }
        
        let alertController = UIAlertController(title: "Updated", message: "Badge count  has been re-calculated", alertAction: .ok(style: .cancel))
        controller.show(alertController, sender: nil)
    }
    
    /// Check if there is any unread conversation, if there is, show an alert with the name and ID of the conversation
    private static func findUnreadConversationContributingToBackArrowDot(_ type: SettingsCellDescriptorType) {
        guard let userSession = ZMUserSession.shared() else { return }
        let predicate = ZMConversation.predicateForConversationConsideredUnreadExcludingSilenced()!
        
        guard let controller = UIApplication.shared.topmostViewController(onlyFullScreen: false) else { return }
        let alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
        
        if let convo = (ZMConversationList.conversations(inUserSession: userSession) as! [ZMConversation])
            .first(where: predicate.evaluate)
        {
            alert.message = ["Found an unread conversation:",
                             "\(convo.displayName)",
                "<\(convo.remoteIdentifier?.uuidString ?? "n/a")>"
                ].joined(separator: "\n")
            alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { _ in
                UIPasteboard.general.string = alert.message
            }))
            
        } else {
            alert.message = "No unread conversation"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller.present(alert, animated: false)
    }
    
    /// Sends a message that will fail to decode on every other device, on the first conversation of the list
    private static func sendBrokenMessage(_ type: SettingsCellDescriptorType) {
        guard
            let userSession = ZMUserSession.shared(),
            let conversation = ZMConversationList.conversationsIncludingArchived(inUserSession: userSession).firstObject as? ZMConversation
            else {
                return
        }
        
        let builder = ZMExternalBuilder()
        _ = builder.setOtrKey("broken_key".data(using: .utf8))
        let genericMessage = ZMGenericMessage.message(content: builder.build())
        
        userSession.enqueueChanges {
            conversation.appendClientMessage(with: genericMessage, expires: false, hidden: false)
        }
    }
    
    private static func reloadUserInterface(_ type: SettingsCellDescriptorType) {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController as? AppRootViewController else {
            return
        }
        
        rootViewController.reload()
    }

    private static func resetCallQualitySurveyMuteFilter(_ type: SettingsCellDescriptorType) {
        guard let controller = UIApplication.shared.topmostViewController(onlyFullScreen: false) else { return }

        CallQualityController.resetSurveyMuteFilter()

        let alert = UIAlertController(
            title: "Success",
            message: "The call quality survey will be displayed after the next call.",
            alertAction: .ok(style: .cancel)
        )
        controller.present(alert, animated: true)
    }
}


