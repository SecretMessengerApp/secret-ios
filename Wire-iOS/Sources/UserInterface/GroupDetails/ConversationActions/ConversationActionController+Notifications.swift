//
import Foundation

enum NotificationResult: CaseIterable {
    case everything, mentionsAndReplies, nothing, cancel
    
    static var title: String {
        return "meta.menu.configure_notification.dialog_message".localized
    }
    
    var mutedMessageTypes: MutedMessageTypes? {
        switch self {
        case .everything:
            return MutedMessageTypes.none
        case .mentionsAndReplies:
            return .regular
        case .nothing:
            return .all
        case .cancel:
            return nil
        }
    }
    
    var title: String {
        return localizationKey.localized
    }
    
    private var localizationKey: String {
        let base = "meta.menu.configure_notification.button_"
        switch self {
        case .everything: return base + "everything"
        case .mentionsAndReplies: return base + "mentions_and_replies"
        case .nothing: return base + "nothing"
        case .cancel: return base + "cancel"
        }
    }
    
    private var style: UIAlertAction.Style {
        switch self {
        case .cancel: return .cancel
        default: return .default
        }
    }
    
    func action(for conversation: ZMConversation, handler: @escaping (NotificationResult) -> Void) -> UIAlertAction {
        let checkmarkText: String
        
        if let mutedMessageTypes = self.mutedMessageTypes, conversation.mutedMessageTypes == mutedMessageTypes {
            checkmarkText = " ✓"
        }
        else {
            checkmarkText = ""
        }
        
        let title = self.title + checkmarkText
        return .init(title: title, style: style, handler: { _ in handler(self) })
    }
}

extension ConversationActionController {

    func requestNotificationResult(for conversation: ZMConversation, handler: @escaping (NotificationResult) -> Void) {
        let title = "\(conversation.displayName) • \(NotificationResult.title)"
        let controller = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        NotificationResult.allCases.map { $0.action(for: conversation, handler: handler) }.forEach(controller.addAction)
        controller.applyTheme()
        present(controller)
    }

    func handleNotificationResult(_ result: NotificationResult, for conversation: ZMConversation) {
        if let mutedMessageTypes = result.mutedMessageTypes {
            ZMUserSession.shared()?.performChanges {
                conversation.mutedMessageTypes = mutedMessageTypes
            }
        }

    }

}
