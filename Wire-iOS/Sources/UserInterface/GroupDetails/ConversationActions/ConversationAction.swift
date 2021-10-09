
import Foundation

extension ZMConversation {

    enum Action: Equatable {
        case deleteGroup
        case moveToFolder
        case removeFromFolder(folder: String)
        case clearContent
        case leave
        case configureNotifications
        case silence(isSilenced: Bool)
        case archive(isArchived: Bool)
        case cancelRequest
        case block(isBlocked: Bool)
        case markRead
        case markUnread
        case remove
        case placeTop(isPlaceTop: Bool)
        case notDisturb(isNotDisturb: Bool)
        case favorite(isFavorite: Bool)
        case shortcut(isShortcut: Bool)
        case addToHomeScreen
    }
    
    var listActions: [Action] {
        return actions.filter({ $0 != .deleteGroup })
    }
    
    var detailActions: [Action] {
        return actions.filter({ $0 != .configureNotifications})
    }
    
    private var actions: [Action] {
        switch conversationType {
        case .connection:
            return availablePendingActions()
        case .oneOnOne:
            return availableOneToOneActions()
        case .self,
             .group,
             .hugeGroup,
             .invalid:
            return availableGroupActions()
        }
    }
    
    private func availableOneToOneActions() -> [Action] {
        precondition(conversationType == .oneOnOne)
        var actions = [Action]()
        actions.append(contentsOf: availableStandardActions())
        actions.append(.clearContent)
        if teamRemoteIdentifier == nil, let connectedUser = connectedUser {
            actions.append(.block(isBlocked: connectedUser.isBlocked))
        }
        return actions
    }
    
    private func availablePendingActions() -> [Action] {
        precondition(conversationType == .connection)
//        return [.archive(isArchived: isArchived), .cancelRequest]
        return [.cancelRequest]
    }
    
    private func availableGroupActions() -> [Action] {
        var actions = availableStandardActions()
        
//        if !isPlacedTop {
//            actions.append(.notDisturb(isNotDisturb: isNotDisturb))
//        }
        
        actions.append(.clearContent)

        if activeParticipants.contains(ZMUser.selfUser()) {
            actions.append(.leave)
        }

        if ZMUser.selfUser()?.canDeleteConversation(self) == true {
            actions.append(.deleteGroup)
        }

        return actions
    }
    
    private func availableStandardActions() -> [Action] {
        var actions: [Action] = []
        
        if [.group, .hugeGroup, .oneOnOne].contains(conversationType) {
            actions.append(.addToHomeScreen)
        }
        

        let isShortcut = Settings.shared.containsShortcutConversation(self)
        actions.append(.shortcut(isShortcut: isShortcut))

        if !isNotDisturb {
            actions.append(.placeTop(isPlaceTop: isPlacedTop))
        }
        if let markReadAction = markAsReadAction() {
            actions.append(markReadAction)
        }
        
        if !isReadOnly {
            if ZMUser.selfUser()?.isTeamMember ?? false {
                actions.append(.configureNotifications)
            }
            else {
                let isSilenced = mutedMessageTypes != .none
                actions.append(.silence(isSilenced: isSilenced))
            }
        }

        return actions
    }
    
    private func markAsReadAction() -> Action? {
        guard Bundle.developerModeEnabled else { return nil }
        if unreadMessages.count > 0 {
            return .markRead
        } else if unreadMessages.count == 0 && canMarkAsUnread() {
            return .markUnread
        }
        return nil
    }
}

extension ZMConversation.Action {

    fileprivate var isDestructive: Bool {
        switch self {
        case .remove,
             .deleteGroup:
            return true
        default: return false
        }
    }
    
    var title: String {
        switch self {
        case .removeFromFolder(let folder):
            return localizationKey.localized(args: folder)
        default:
            return localizationKey.localized
        }
    }
    
    private var localizationKey: String {
        switch self {
        case .deleteGroup: return "meta.menu.delete"
        case .moveToFolder: return "meta.menu.move_to_folder"
        case .removeFromFolder: return "meta.menu.remove_from_folder"
        case .remove: return "profile.remove_dialog_button_remove"
        case .clearContent: return "meta.menu.clear_content"
        case .leave: return "meta.menu.leave"
        case .markRead: return "meta.menu.mark_read"
        case .markUnread: return "meta.menu.mark_unread"
        case .configureNotifications: return "meta.menu.configure_notifications"
        case .silence(isSilenced: let muted): return "meta.menu.silence.\(muted ? "unmute" : "mute")"
        case .archive(isArchived: let archived): return "meta.menu.\(archived ? "unarchive" : "archive")"
        case .cancelRequest: return "meta.menu.cancel_connection_request"
        case .block(isBlocked: let blocked): return blocked ? "profile.unblock_button_title" : "profile.block_button_title"
        case .placeTop(isPlaceTop: let placeTop): return placeTop ? "meta.menu.cancel_place_top" : "meta.menu.place_top"
        case .notDisturb(isNotDisturb: let notDisturb): return notDisturb ? "meta.menu.cancel_do_not_disturb_group" : "meta.menu.add_do_not_disturb_group"
        case .favorite(isFavorite: let favorited): return favorited ? "profile.unfavorite_button_title" : "profile.favorite_button_title"
        case .shortcut(isShortcut:  let isShortcut):
            return isShortcut ?  "conversation.setting.to.group.noShortcut" : "conversation.setting.to.group.shortcut"
        case .addToHomeScreen: return "conversation.setting.to.group.add_to_home_screen"
        }
    }
    
    func alertAction(handler: @escaping () -> Void) -> UIAlertAction {
        return .init(title: title, style: isDestructive ? .destructive : .default) { _ in handler() }
    }

    func previewAction(handler: @escaping () -> Void) -> UIPreviewAction {
        return .init(title: title, style: isDestructive ? .destructive : .default, handler: { _, _ in handler() })
    }
}
