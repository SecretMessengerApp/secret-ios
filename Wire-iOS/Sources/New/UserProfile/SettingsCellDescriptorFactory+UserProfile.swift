//
//  SettingsCellDescriptorFactory+UserProfile.swift
//  Wire-iOS
//

import Foundation

public enum SettingsCellDescriptorId: String {
    case createConversation = "SettingsCellDescriptorIdCreateConversation"
    case conversationRecord = "SettingsCellDescriptorIdConversationRecord"
    case shortcutConversation = "SettingsCellDescriptorIdShortcutConversation"
    case removePeople = "SettingsCellDescriptorIdRemovePeople"
    case startChat = "SettingsCellDescriptorIdStartChat"
//    case photo = "SettingsCellDescriptorIdPhoto"
//    case destoryAfterRead = "SettingsCellDescriptorIdDestoryAfterRead"
}

public enum UserProfileStatusValueType: Int16 {
    case close = 0
    case darwin = 1
    case angel = 2
    case campusBelle = 3
    case aI = 4
    case zuChongZhi = 5
}

extension SettingsCellDescriptorFactory {

    
    func simpleUserProfileGroup() -> SettingsControllerGeneratorType & SettingsInternalGroupCellDescriptorType {

        guard let safeUser = user, !safeUser.isSelfUser else {
            let settingSection = SettingsSectionDescriptor(cellDescriptors: [])
            return SettingsGroupCellDescriptor(items: [settingSection], title: "self.profile".localized, style: .plain)
        }
        
        guard safeUser.isConnected else {
            let settingSection = SettingsSectionDescriptor(cellDescriptors: [addFriendCell()])
            return SettingsGroupCellDescriptor(items: [settingSection], title: "self.profile".localized, style: .plain)
        }
        
        let settingSection = SettingsSectionDescriptor(cellDescriptors: [startChatCell()])
        return SettingsGroupCellDescriptor(items: [settingSection], title: "self.profile".localized, style: .plain)
    }
    

    func userProfileGroup(_ isCreater: Bool = false, groupConversation: ZMConversation? = nil) -> SettingsControllerGeneratorType & SettingsInternalGroupCellDescriptorType {

        self.groupConversation = groupConversation
        let fromGroup = groupConversation != nil
        let isManager: Bool = groupConversation?.manager?.contains(ZMUser.selfUser()!.remoteIdentifier.transportString()) ?? false
        let canManager: Bool = (isManager && (user != groupConversation?.creator) && !groupConversation!.manager!.contains(user!.remoteIdentifier.transportString()) )
       
        var safetyElements: [SettingsCellDescriptorType] = []
        var convElements: [SettingsCellDescriptorType] = []
        var settingElements: [SettingsCellDescriptorType] = []
        let handerDescriptor = SettingsInfoCellDescriptor(title: "self.settings.account_section.handle.title".localized) {[weak self]_ in
            if let handle = self?.user?.handle {
                return SettingsCellPreview.textAndValue(handle)
            } else {
                return SettingsCellPreview.textAndValue("")
            }
        }
        
        if let safeConversation = groupConversation, safeConversation.isAllowMemberAddEachOther || isCreater {
            safetyElements.append(handerDescriptor)
        }
        

        guard let safeUser = user, !safeUser.isSelfUser else {
            let settingSection = SettingsSectionDescriptor(cellDescriptors: safetyElements)
            return SettingsGroupCellDescriptor(items: [settingSection], title: "self.profile".localized, style: .plain)
        }
        guard safeUser.isConnected else {
            if isCreater || canManager {
         
                safetyElements.append(disableSendMsgCell())
            }
 
            
            // TODO: if user state is connection, add already connected cell
            if let safeConversation = groupConversation {
                if safeConversation.isAllowMemberAddEachOther || isCreater {
                    safetyElements.append(addFriendCell())
                }
            } else {
                safetyElements.append(addFriendCell())
            }
            
            if isCreater || canManager {
           
                safetyElements.append(self.removeParticipantCell())
            }
            

            settingElements.append(complaintCell())
            
            let settingSection = SettingsSectionDescriptor(cellDescriptors: safetyElements)
            return SettingsGroupCellDescriptor(items: [settingSection], title: "self.profile".localized, style: .plain)
        }
        
        safetyElements.append(safeCellWithUser(user: safeUser))
        

        if !fromGroup {
            convElements.append(destroyAfterReadCellWithUser())
        }

        if fromGroup,
            (isCreater || canManager),
            safeUser != ZMUser.selfUser() {
            safetyElements.append(disableSendMsgCell())
        }


        safetyElements.append(remarkCell())


        if !fromGroup, let safeUser = user {
            convElements.append(self.statusCell(user: safeUser))
        }

        if !fromGroup {
            convElements.append(self.conversationRecordCell())

            if let conversation = conversation {
                convElements.append(chooseImage(conversation: conversation))
            }
        }


        let silencedCell = SettingsPropertyToggleCellDescriptor(settingsProperty: self.settingsPropertyFactory.property(.silenced), inverse: false, identifier: nil)
        settingElements.append(silencedCell)
        

        if !fromGroup {
            settingElements.append(addToHomeScreenCell())
            settingElements.append(self.shortcutConversationCell())
        }


        let blockedCell = SettingsPropertyToggleCellDescriptor(settingsProperty: self.settingsPropertyFactory.property(.blocked), inverse: false, identifier: nil)
        settingElements.append(blockedCell)
        

        if !fromGroup {
            let placeTopCell = SettingsPropertyToggleCellDescriptor(settingsProperty: self.settingsPropertyFactory.property(.placeTop), inverse: false, identifier: nil)
            settingElements.append(placeTopCell)
        }

        if !fromGroup {
            let screenShotCell = SettingsExternalScreenCellDescriptor(
                title: "conversation.setting.screenShot".localized,
                isDestructive: false,
                presentationStyle: .modal,
                identifier: nil,
                presentationAction: { () -> (UIViewController?) in
                    return nil
                },
                previewGenerator: { (_) -> SettingsCellPreview in
                    SettingsCellPreview.text("conversation.setting.screenShot.open".localized)
                },
                accessoryViewMode: AccessoryViewMode.alwaysHide
            )
            settingElements.append(screenShotCell)
        }

  
        if !fromGroup {
            settingElements.append(self.createConversationCell())
        }


        if isCreater || canManager {
            settingElements.append(self.removeParticipantCell())
        }

        if fromGroup {
            settingElements.append(self.startChatCell())
        }
        

        settingElements.append(complaintCell())
        
        let settingSection = SettingsSectionDescriptor(cellDescriptors: settingElements)
        let cnvSection = SettingsSectionDescriptor(cellDescriptors: convElements)
        let safetySection = SettingsSectionDescriptor(cellDescriptors: safetyElements)

        return SettingsGroupCellDescriptor(items: [safetySection, cnvSection, settingSection], title: "self.profile".localized, style: .grouped)
    }

    func safeCellWithUser(user: ZMUser) -> SettingsCellDescriptorType {
        return SettingsExternalScreenCellDescriptor(
            title: "newProfile.conversation.safe.title".localized,
            detailTitle: "newProfile.conversation.safe.subtitle".localized,
            isDestructive: false,
            presentationStyle: .navigation,
            presentationAction: { () -> (UIViewController?) in
                let viewController = ProfileViewController.init(user: user, viewer: ZMUser.selfUser(), context: .deviceList)
                return viewController
            },
            previewGenerator: { _ in
                return SettingsCellPreview.image(StyleKitIcon.lock.makeImage(size: .tiny, color: .black), false)
            },
            icon: .none,
            accessoryViewMode: .alwaysShow
        )
    }


    func statusCell(user: ZMUser) -> SettingsCellDescriptorType {

        let titleLabel = "self.settings.status.title".localized
        let statusProperty = self.settingsPropertyFactory.property(.status)

        let closeAlerts = SettingsPropertySelectValueCellDescriptor(settingsProperty: statusProperty,
                                                                    value: SettingsPropertyValue(UserProfileStatusValueType.close.rawValue),
                                                                    title: "self.settings.status.closed".localized)

        let darwinAlerts = SettingsPropertySelectValueCellDescriptor(settingsProperty: statusProperty,
                                                                     value: SettingsPropertyValue(UserProfileStatusValueType.darwin.rawValue),
                                                                     title: "self.settings.status.darwin".localized)

        let aiAlerts = SettingsPropertySelectValueCellDescriptor(settingsProperty: statusProperty,
                                                                 value: SettingsPropertyValue(UserProfileStatusValueType.aI.rawValue),
                                                                 title: "self.settings.status.ai".localized)
        let zuChongZhiAlerts = SettingsPropertySelectValueCellDescriptor(settingsProperty: statusProperty,
                                                                         value: SettingsPropertyValue(UserProfileStatusValueType.zuChongZhi.rawValue),
                                                                         title: "self.settings.status.zuchongzhi".localized)
        //
        var cellDescriptors = [closeAlerts]

        let alertsSection = SettingsSectionDescriptor(cellDescriptors: cellDescriptors, header: titleLabel)

        let alertPreviewGenerator: PreviewGeneratorType = {
            let value = statusProperty.value()
            guard let rawValue = value.value() as? NSNumber,
                let statuValue = UserProfileStatusValueType.init(rawValue: rawValue.int16Value) else { return .text($0.title) }

            switch statuValue {
            case .close:
                return .text("self.settings.status.closed".localized)
            case .darwin:
                return .text("self.settings.status.darwin".localized)
            case .angel:
                return .text("self.settings.status.angel".localized)
            case .campusBelle:
                return .text("self.settings.status.campusbelle".localized)
            case .aI:
                return .text("self.settings.status.ai".localized)
            case .zuChongZhi:
                return .text("self.settings.status.zuchongzhi".localized)
            }

        }
        return SettingsGroupCellDescriptor(items: [alertsSection], title: titleLabel, previewGenerator: alertPreviewGenerator)
    }


    func destroyAfterReadCellWithUser() -> SettingsCellDescriptorType {
        
        return SettingsExternalScreenCellDescriptor(
            title: "conversation.input_bar.placeholder_ephemeral".localized,
            detailTitle: conversation?.destructionTimeout?.localizedText ??
            "group_details.guest_options_cell.disabled".localized,
            isDestructive: false,
            presentationStyle: .navigation,
            presentationAction: { () -> (UIViewController?) in
                guard let conversation = self.conversation else { return nil }
                let menuVC = ConversationTimeoutOptionsViewController(conversation: conversation, userSession: .shared()!, needSync: false)
                return menuVC
        },
            icon: .none,
            accessoryViewMode: .alwaysShow)
    }
    

    func remarkCell() -> SettingsCellDescriptorType {
        return SettingsPropertyTextValueCellDescriptor(settingsProperty: settingsPropertyFactory.property(.remarks))
    }
    

    func conversationRecordCell() -> SettingsCellDescriptorType {
        return SettingsExternalScreenCellDescriptor(title: "newProfile.conversation.record".localized,
                                                    isDestructive: false,
                                                    presentationStyle: PresentationStyle.modal,
                                                    identifier: SettingsCellDescriptorId.conversationRecord.rawValue,
                                                    presentationAction: { () -> (UIViewController?)  in
                                                        return nil
        },
                                                    accessoryViewMode: .alwaysShow)
    }
    

    func shortcutConversationCell() -> SettingsCellDescriptorType {
        return SettingsPropertyToggleCellDescriptor(settingsProperty: self.settingsPropertyFactory.property(.shortcut), inverse: false, identifier: nil)
    }
    

    func addToHomeScreenCell() -> SettingsCellDescriptorType {
        SettingsButtonCellDescriptor(
            title: "conversation.setting.to.group.add_to_home_screen".localized,
            isDestructive: false) { [weak self] _ in
            guard let conv = self?.conversation else { return }
            ConversationAddToHomeScreenController(conversation: conv).addToHomeScreen()
        }
    }


    func createConversationCell() -> SettingsCellDescriptorType {
        return SettingsExternalScreenCellDescriptor(title: "peoplepicker.button.create_conversation".localized,
                                                    isDestructive: false,
                                                    presentationStyle: PresentationStyle.modal,
                                                    identifier: SettingsCellDescriptorId.createConversation.rawValue,
                                                    presentationAction: { () -> (UIViewController?) in
                                                        return nil
        },
                                                    previewGenerator: nil,
                                                    accessoryViewMode: .alwaysShow)
    }

    func chooseImage(conversation: ZMConversation) -> SettingsCellDescriptorType {
        return SettingsExternalScreenCellDescriptor(
            title: "conversation.setting.backgroundimage".localized,
            isDestructive: false,
            presentationStyle: .navigation,
            presentationAction: { () -> (UIViewController?) in
                return WBConvBGSelectVC(conversionId: conversation.remoteIdentifier?.uuidString)
            },
            accessoryViewMode: .alwaysShow
        )
    }


    ///
    /// - Returns:
    func removeParticipantCell() -> SettingsCellDescriptorType {
        return SettingsExternalScreenCellDescriptor(title: "newProfile.conversation.remove_participant".localized,
                                                    isDestructive: false,
                                                    presentationStyle: PresentationStyle.modal,
                                                    identifier: SettingsCellDescriptorId.removePeople.rawValue,
                                                    presentationAction: { () -> (UIViewController?) in
                                                        return nil
        },
                                                    previewGenerator: nil,
                                                    accessoryViewMode: .alwaysShow)
    }

    func startChatCell() -> SettingsCellDescriptorType {
        return SettingsExternalScreenCellDescriptor(title: "newProfile.conversation.start_chat".localized,
                                                    isDestructive: false,
                                                    presentationStyle: PresentationStyle.modal,
                                                    identifier: SettingsCellDescriptorId.startChat.rawValue,
                                                    presentationAction: { () -> (UIViewController?) in
                                                        return nil
        },
                                                    previewGenerator: nil,
                                                    accessoryViewMode: .alwaysShow)
    }
    

    func disableSendMsgCell() -> SettingsCellDescriptorType {

        let previewGenerator: PreviewGeneratorType = {_ in
            guard
                let groupConversation = self.settingsPropertyFactory.groupConversation,
                let context = groupConversation.managedObjectContext,
                let userID = self.user?.remoteIdentifier.transportString(),
                let conversationID = groupConversation.remoteIdentifier?.transportString(),
                let blockTime = UserDisableSendMsgStatus.getBlockTime(managedObjectContext: context, user: userID, conversation: conversationID)
            else {
                return .none
            }
            let blockTimeStamp = blockTime.doubleValue
            if blockTimeStamp == 0 ||
                (Date.timeIntervalSinceReferenceDate > blockTimeStamp && blockTimeStamp != -1) {
                return .none
            }
            return .text("conversation.setting.disableSendMsg.status.ing".localized)
        }
        
        return SettingsExternalScreenCellDescriptor(
            title: "conversation.setting.disableSendMsg".localized,
            isDestructive: false,
            presentationStyle: .navigation,
            presentationAction: { () -> (UIViewController?) in
                guard let conversation = self.groupConversation, let curuser = self.user else { return nil }
                let menuVC = ConversationSendDisableOptionsViewController(conversation: conversation, userSession: .shared()!, user: curuser)
                return menuVC
        },
            previewGenerator: previewGenerator,
            icon: .none,
            accessoryViewMode: .alwaysShow)
    }
    
    
    func addFriendCell() -> SettingsCellDescriptorType {
        return SettingsExternalScreenCellDescriptor(
            title: "connection_request.send_button_title".localized,
            isDestructive: false,
            presentationStyle: .modal,
            identifier: SettingsCellDescriptorId.shortcutConversation.rawValue,
            presentationAction: { [weak self] () -> (UIViewController?)  in
                guard let self = self else { return nil }
                ZMUserSession.shared()?.enqueueChanges {
                    let messageText = "missive.connection_request.default_message".localized(args: self.user?.displayName ?? "", ZMUser.selfUser().name ?? "")
                    self.user?.connect(message: messageText)
                    delay(0.5) { HUD.success("hud.success.sent".localized) }
                }
                return nil
            },
            accessoryViewMode: .alwaysHide
        )
    }
    

    func complaintCell() -> SettingsCellDescriptorType {
        return SettingsExternalScreenCellDescriptor(
            title: "newProfile.conversation.complaint".localized,
            isDestructive: false,
            presentationStyle: .navigation,
            presentationAction: { () -> (UIViewController?) in
                
                return ComplaintUserViewController()
        },
            accessoryViewMode: .alwaysShow
        )
    }
}
