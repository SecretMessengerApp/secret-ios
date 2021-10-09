
import UIKit

struct AddParticipantsViewModel {
    let context: AddParticipantsViewController.Context
    let variant: ColorSchemeVariant
    
    init(with context: AddParticipantsViewController.Context, variant: ColorSchemeVariant) {
        self.context = context
        self.variant = variant
    }
    
    var botCanBeAdded: Bool {
        switch context {
        case .create: return false
        case .add(let conversation): return conversation.botCanBeAdded
        case .select: return false
        case .inviteFriends: return false
        }
    }
    
    var selectedUsers: [ZMUser] {
        switch context {
        case .add(let conversation) where conversation.conversationType == .oneOnOne:
            return conversation.connectedUser.map { [$0] } ?? []
        case .create(let values): return Array(values.participants)
        default: return []
        }
    }
    
    func title(with users: Set<ZMUser>) -> String {
        switch context {
        case .select(let title): return title
        default:
            return users.isEmpty
                ? "peoplepicker.group.title.singular".localized(uppercased: true)
                : "peoplepicker.group.title.plural".localized(uppercased: true, args: users.count)
        }
    }
    
    var filterConversation: ZMConversation? {
        switch context {
        case .add(let conversation) where [.group, .hugeGroup].contains(conversation.conversationType): return conversation
        default: return nil
        }
    }
    
    var showsConfirmButton: Bool {
        switch context {
        case .add: return true
        case .create: return false
        case .select: return true
        case .inviteFriends: return true
        }
    }
    
    var confirmButtonTitle: String? {
        switch context {
        case .create: return nil
        case .add(let conversation):
            if conversation.conversationType == .oneOnOne {
                return "peoplepicker.button.create_conversation".localized(uppercased: true)
            } else {
                return "peoplepicker.button.add_to_conversation".localized(uppercased: true)
            }
        case .select: return "controller.alert.ok".localized
        case .inviteFriends: return "contacts_ui.action_button.invite".localized
        }
    }
    
    func rightNavigationItem(target: AnyObject, action: Selector) -> UIBarButtonItem {
        switch context {
        case .add:
            let item = UIBarButtonItem(icon: .cross, target: target, action: action)
            item.accessibilityIdentifier = "close"
            return item
        case .create(let values):
            let key = values.participants.isEmpty ? "peoplepicker.group.skip" : "peoplepicker.group.done"
            let item = UIBarButtonItem(title: key.localized(uppercased: true), style: .plain, target: target, action: action)
            item.tintColor = UIColor.accent()
            item.accessibilityIdentifier = values.participants.isEmpty ? "button.addpeople.skip" : "button.addpeople.create"
            return item
        case .select:
            let item = UIBarButtonItem(icon: .cross, target: target, action: action)
            item.accessibilityIdentifier = "close"
            return item
        case .inviteFriends:
            let item = UIBarButtonItem(icon: .cross, target: target, action: action)
            item.accessibilityIdentifier = "close"
            return item
        }
    }
    
}
