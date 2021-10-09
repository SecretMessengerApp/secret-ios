
import Foundation

enum CancelConnectionRequestResult {
    case cancelRequest, cancel
    
    var title: String {
        return localizationKey.localized
    }
    
    private var localizationKey: String {
        switch self {
        case .cancel: return "profile.cancel_connection_request_dialog.button_no"
        case .cancelRequest: return "profile.cancel_connection_request_dialog.button_yes"
        }
    }
    
    private var style: UIAlertAction.Style {
        guard case .cancel = self else { return .destructive }
        return .cancel
    }
    
    func action(_ handler: @escaping (CancelConnectionRequestResult) -> Void) -> UIAlertAction {
        return .init(title: title, style: style) { _ in handler(self) }
    }
    
    static func title(for user: ZMUser) -> String {
        return "profile.cancel_connection_request_dialog.message".localized(args: user.displayName)
    }
    
    static var all: [CancelConnectionRequestResult] {
        return [.cancelRequest, .cancel]
    }
    
    static func controller(for user: ZMUser, handler: @escaping (CancelConnectionRequestResult) -> Void) -> UIAlertController {
        let controller = UIAlertController(title: title(for: user), message: nil, preferredStyle: .actionSheet)
        controller.applyTheme()
        all.map { $0.action(handler) }.forEach(controller.addAction)
        return controller
    }
}

extension UIAlertController {
    @objc(cancelConnectionRequestControllerForUser:completion:)
    static func cancelConnectionRequest(for user: ZMUser, completion: @escaping (Bool) -> Void) -> UIAlertController {
        return CancelConnectionRequestResult.controller(for: user) { result in
            completion(result == .cancel)
        }
    }
}

extension ConversationActionController {
    
    func requestCancelConnectionRequestResult(for user: ZMUser, handler: @escaping (CancelConnectionRequestResult) -> Void) {
        let controller = CancelConnectionRequestResult.controller(for: user, handler: handler)
        present(controller)
    }
    
    func handleConnectionRequestResult(_ result: CancelConnectionRequestResult, for conversation: ZMConversation) {
        guard case .cancelRequest = result else { return }
        enqueue {
            conversation.connectedUser?.cancelConnectionRequest()
        }
    }
    
}
