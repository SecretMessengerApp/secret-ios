

import Foundation


/**
 * Top-level structure overview:
 * Settings group (screen) @c SettingsGroupCellDescriptorType contains
 * |--Settings section (table view section) @c SettingsSectionDescriptorType
 * |   |--Cell @c SettingsCellDescriptorType
 * |   |--Subgroup @c SettingsGroupCellDescriptorType
 * |   |  \..
 * |   \..
 * \...
 */

// MARK: - Protocols

/**
 * @abstract Top-level protocol for model object of settings. Describes the way cell should be created or how the value
 * should be updated from the cell.
 */
protocol SettingsCellDescriptorType: class {
    static var cellType: SettingsTableCell.Type {get}
    var visible: Bool {get}
    var title: String {get}
    var identifier: String? {get}
    var group: SettingsGroupCellDescriptorType? {get}
    var detailTitle: String {get}
    
    func select(_: SettingsPropertyValue?)
    func featureCell(_: SettingsCellType)
}

extension SettingsCellDescriptorType{
    var detailTitle: String {
        get{
            return ""
        }
    }
}

func ==(left: SettingsCellDescriptorType, right: SettingsCellDescriptorType) -> Bool {
    if let leftID = left.identifier,
        let rightID = right.identifier {
            return leftID == rightID
    }
    else {
        return left == right
    }
}

typealias PreviewGeneratorType = (SettingsCellDescriptorType) -> SettingsCellPreview

protocol SettingsGroupCellDescriptorType: SettingsCellDescriptorType {
    var viewController: UIViewController? {get set}
}

protocol SettingsSectionDescriptorType: class {
    var cellDescriptors: [SettingsCellDescriptorType] {get}
    var visibleCellDescriptors: [SettingsCellDescriptorType] {get}
    var header: String? {get}
    var footer: String? {get}
    var visible: Bool {get}
}

extension SettingsSectionDescriptorType {
    func allCellDescriptors() -> [SettingsCellDescriptorType] {
        return cellDescriptors
    }
}

enum InternalScreenStyle {
    case plain
    case grouped
}

protocol SettingsInternalGroupCellDescriptorType: SettingsGroupCellDescriptorType {
    var items: [SettingsSectionDescriptorType] {get}
    var visibleItems: [SettingsSectionDescriptorType] {get}
    var style: InternalScreenStyle {get}
}

extension SettingsInternalGroupCellDescriptorType {
    func allCellDescriptors() -> [SettingsCellDescriptorType] {
        return items.flatMap({ (section: SettingsSectionDescriptorType) -> [SettingsCellDescriptorType] in
            return section.allCellDescriptors()
        })
    }
}

protocol SettingsExternalScreenCellDescriptorType: SettingsGroupCellDescriptorType {
    var presentationAction: () -> (UIViewController?) {get}
}

protocol SettingsPropertyCellDescriptorType: SettingsCellDescriptorType {
    var settingsProperty: SettingsProperty {get}
}

protocol SettingsControllerGeneratorType {
    func generateViewController() -> UIViewController?
}

// MARK: - Classes

class SettingsSectionDescriptor: SettingsSectionDescriptorType {
    let cellDescriptors: [SettingsCellDescriptorType]
    var visibleCellDescriptors: [SettingsCellDescriptorType] {
        return self.cellDescriptors.filter {
            $0.visible
        }
    }
    var visible: Bool {
        return visibilityAction?(self) ?? true
    }
    let visibilityAction: ((SettingsSectionDescriptorType) -> (Bool))?

    var header: String? {
        return headerGenerator()
    }
    var footer: String? {
        return footerGenerator()
    }
    
    let headerGenerator: () -> String?
    let footerGenerator: () -> String?
    
    convenience init(cellDescriptors: [SettingsCellDescriptorType], header: String? = .none, footer: String? = .none, visibilityAction: ((SettingsSectionDescriptorType) -> (Bool))? = .none) {
        self.init(cellDescriptors: cellDescriptors, headerGenerator: { return header }, footerGenerator: { return footer}, visibilityAction: visibilityAction)
    }
    
    init(cellDescriptors: [SettingsCellDescriptorType], headerGenerator: @escaping () -> String?, footerGenerator: @escaping () -> String?, visibilityAction: ((SettingsSectionDescriptorType) -> (Bool))? = .none) {
        self.cellDescriptors = cellDescriptors
        self.headerGenerator = headerGenerator
        self.footerGenerator = footerGenerator
        self.visibilityAction = visibilityAction
    }
}


class SettingsGroupCellDescriptor: SettingsInternalGroupCellDescriptorType, SettingsControllerGeneratorType {
    static let cellType: SettingsTableCell.Type = SettingsGroupCell.self
    var visible: Bool = true
    let title: String
    let style: InternalScreenStyle
    let items: [SettingsSectionDescriptorType]
    let identifier: String?
    let icon: StyleKitIcon?
    
    let previewGenerator: PreviewGeneratorType?
    
    weak var group: SettingsGroupCellDescriptorType?
    
    var visibleItems: [SettingsSectionDescriptorType] {
        return self.items.filter {
            $0.visible
        }
    }
    
    weak var viewController: UIViewController?
    
    init(items: [SettingsSectionDescriptorType], title: String, style: InternalScreenStyle = .grouped, identifier: String? = .none, previewGenerator: PreviewGeneratorType? = .none, icon: StyleKitIcon? = nil) {
        self.items = items
        self.title = title
        self.style = style
        self.identifier = identifier
        self.previewGenerator = previewGenerator
        self.icon = icon
    }
    
    func featureCell(_ cell: SettingsCellType) {
        cell.titleText = self.title
        if let previewGenerator = self.previewGenerator {
            let preview = previewGenerator(self)
            cell.preview = preview
        }
        cell.icon = self.icon
    }
    
    func select(_ value: SettingsPropertyValue?) {
        if let controllerToPush = self.generateViewController() {
            self.viewController?.wr_splitViewController?.pushToRightPossible(controllerToPush, from: self.viewController)
        }
        
//        if let navigationController = self.viewController?.navigationController,
//           let controllerToPush = self.generateViewController() {
//            navigationController.pushViewController(controllerToPush, animated: true)
//        }
    }
    
    func generateViewController() -> UIViewController? {
        return SettingsTableViewController(group: self)
    }
}

// MARK: - Helpers

extension SettingsPropertyName {
    
    var settingsPropertyLabelText: String {
        switch self {
        case .chatHeadsDisabled:
            return "self.settings.notifications.chat_alerts.toggle".localized
        case .notificationContentVisible:
            return "self.settings.notifications.push_notification.toogle".localized
        case .disableMarkdown:
            return "Disable Markdown support"
            
        case .darkMode:
            return "self.settings.account_picture_group.theme".localized
        // Profile
        case .profileName:
            return "self.settings.account_section.name.title".localized
            
        case .handle:
            return "self.settings.account_section.handle.title".localized
            
        case .email:
            return "self.settings.account_section.email.title".localized
        case .phone:
            return "self.settings.account_section.phone.title".localized
            
        // AVS
        case .soundAlerts:
            return "self.settings.sound_menu.title".localized
            
        case .messageSoundName:
            return "self.settings.sound_menu.message.title".localized
        case .callSoundName:
            return "self.settings.sound_menu.ringtone.title".localized
        case .pingSoundName:
            return "self.settings.sound_menu.ping.title".localized
        case .accentColor:
            return "self.settings.account_picture_group.color".localized
        case .disableSendButton:
            return "self.settings.popular_demand.send_button.title".localized
        case .disableCallKit:
            return "self.settings.callkit.caption".localized
        case .tweetOpeningOption:
            return "self.settings.link_options.twitter.title".localized
        case .mapsOpeningOption:
            return "self.settings.link_options.maps.title".localized
        case .browserOpeningOption:
            return "self.settings.link_options.browser.title".localized
        case .callingProtocolStrategy:
            return "Calling protocol"
        case .enableBatchCollections:
            return "Use AssetCollectionBatched"
        case .lockApp:
            return "self.settings.privacy_security.lock_app".localized
        case .callingConstantBitRate:
            return "self.settings.vbr.title".localized
        case .disableLinkPreviews:
            return "self.settings.privacy_security.disable_link_previews.title".localized
            
        // personal information - Analytics
        case .disableCrashAndAnalyticsSharing:
            return "self.settings.privacy_analytics.title".localized
        case .receiveNewsAndOffers:
            return "self.settings.receiveNews_and_offers.title".localized
        case .readReceiptsEnabled:
            return "self.settings.enable_read_receipts.title".localized
        case .remarks:
            return "newProfile.conversation.remark".localized
  
        case .silenced:
            return "conversation_list.voiceover.status.silenced".localized

        case .placeTop:
            return "conversation.setting.place_top".localized
        case .disableSendMsg:
            return "conversation.setting.disableSendMsg".localized
    
            //    case .openUrlJoin:
            //        return "conversation.setting.to.openjoin.url".localized
            //    case .groupInviteUrl:
            //        return " "
      
            //    case .openQrcodeJoin:
            //        return "conversation.setting.to.openjoin.QRCode".localized
            //    
            //    case .toBeHugeConversation:
            //        return "conversation.setting.to.huge.conversation".localized

        case .blocked:
            return "profile.block_dialog.button_block".localized
     
            //    case .removed:
            //        return "newProfile.conversation.remove_participant".localized
       
            //    case .startChat:
            //        return "newProfile.conversation.start_chat".localized

        case .status:
            return  "self.settings.status.title".localized
      
            //    case .destoryAfterReadStatus:
            //        return  "conversation.status.message.ephemeral".localized
            //
            //    case .conversationName:
            //        return "participants.conversation.name".localized
            //    case .remark:
            //        return "profile_view.accessibility.name".localized
            //
        case .conversationAppNotice:
            return "conversation.app.notice.setting.reminder".localized
        case .shortcut:
            return "conversation.setting.to.group.shortcut".localized
        default:
            return ""
        }
    }
}


