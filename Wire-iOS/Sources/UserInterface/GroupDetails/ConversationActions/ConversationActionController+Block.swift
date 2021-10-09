
import Foundation

enum BlockResult {
    case block(isBlocked: Bool), cancel
    
    var title: String {
        return localizationKey.localized
    }
    
    private var localizationKey: String {
        switch self {
        case .cancel: return "profile.block_dialog.button_cancel"
        case .block(isBlocked: false): return "profile.block_button_title_action"
        case .block(isBlocked: true): return "profile.unblock_button_title_action"
        }
    }
    
    private var style: UIAlertAction.Style {
        guard case .cancel = self else { return .destructive }
        return .cancel
    }
    
    func action(_ handler: @escaping (BlockResult) -> Void) -> UIAlertAction {
        return .init(title: title, style: style) { _ in handler(self) }
    }
    
    static func title(for user: UserType) -> String? {
        // Do not show the title if the user is already blocked and we want to unblock them.
        if user.isBlocked {
            return nil
        }

        return "profile.block_dialog.message".localized(args: user.displayName)
    }
    
    static func all(isBlocked: Bool) -> [BlockResult] {
        return [.block(isBlocked: isBlocked), .cancel]
    }
}

extension ConversationActionController {
    
    func requestBlockResult(for conversation: ZMConversation, handler: @escaping (BlockResult) -> Void) {
        guard let user = conversation.connectedUser else { return }
        let controller = UIAlertController(title: BlockResult.title(for: user), message: nil, preferredStyle: .actionSheet)
        BlockResult.all(isBlocked: user.isBlocked).map { $0.action(handler) }.forEach(controller.addAction)
        controller.applyTheme()
        present(controller)
    }
    
    func handleBlockResult(_ result: BlockResult, for conversation: ZMConversation) {
        guard case .block = result else { return }
        ZClientViewController.shared?.transitionToList(animated: true) {
            conversation.connectedUser?.toggleBlocked()
        }
    }
    
}
