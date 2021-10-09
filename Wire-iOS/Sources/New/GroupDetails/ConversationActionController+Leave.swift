//
//  GroupDetailsViewController+Leave.swift
//  Wire-iOS
//


import Foundation

enum LeaveResult: AlertResultConfiguration {
    case leave(delete: Bool), cancel
    
    var title: String {
        return localizationKey.localized
    }
    
    private var localizationKey: String {
        switch self {
        case .cancel: return "general.cancel"
        case .leave(delete: true): return "meta.leave_conversation_button_leave_and_delete"
        case .leave(delete: false): return "meta.leave_conversation_button_leave"
        }
    }
    
    private var style: UIAlertAction.Style {
        guard case .cancel = self else { return .destructive }
        return .cancel
    }
    
    func action(_ handler: @escaping (LeaveResult) -> Void) -> UIAlertAction {
        return .init(title: title, style: style) { _ in handler(self) }
    }
    
    static var title: String {
        return "meta.leave_conversation_dialog_message".localized
    }
    
    static var all: [LeaveResult] {
        return [.leave(delete: true), .leave(delete: false), .cancel]
    }
}

extension ConversationActionController {
    
    func handleLeaveResult(_ result: LeaveResult, for conversation: ZMConversation) {
        guard case .leave(delete: let delete) = result else { return }
             transitionToListAndEnqueue {
                if delete {
                    conversation.clearMessageHistory()
                }
                conversation.removeOrShowError(participnant: .selfUser())
            }
        }

    
}

