
import Foundation


extension CellConfiguration {

    static func allowGuestsToogle(get: @escaping () -> Bool, set: @escaping (Bool) -> Void) -> CellConfiguration {
        return .toggle(
            title: "guest_room.allow_guests.title".localized,
            subtitle: "guest_room.allow_guests.subtitle".localized,
            identifier: "toggle.guestoptions.allowguests",
            get: get,
            set: set
        )
    }
    
    static func createLinkButton(action: @escaping Action) -> CellConfiguration {
        return .leadingButton(
            title: "guest_room.link.button.title".localized,
            identifier: "",
            action: action
        )
    }
    
    static func copyLink(action: @escaping Action) -> CellConfiguration {
        return .iconAction(
            title: "guest_room.actions.copy_link".localized,
            icon: .copy,
            color: nil,
            action: action
        )
    }
    
    static let copiedLink: CellConfiguration = .iconAction(
            title: "guest_room.actions.copied_link".localized,
            icon: .checkmark,
            color: nil,
            action: {_ in }
        )
    
    static func shareLink(action: @escaping Action) -> CellConfiguration {
        return .iconAction(
            title: "guest_room.actions.share_link".localized,
            icon: .export,
            color: nil,
            action: action
        )
    }
    
    static func revokeLink(action: @escaping Action) -> CellConfiguration {
        return .iconAction(
            title: "guest_room.actions.revoke_link".localized,
            icon: .cross,
            color: nil,
            action: action
        )
    }

}
