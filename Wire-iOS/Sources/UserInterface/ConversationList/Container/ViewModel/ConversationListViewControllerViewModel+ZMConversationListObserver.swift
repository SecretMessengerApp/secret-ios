

import Foundation

extension ConversationListViewController.ViewModel: ZMConversationListObserver {
    public func conversationListDidChange(_ changeInfo: ConversationListChangeInfo) {
        updateNoConversationVisibility()
        updateArchiveButtonVisibility()
    }
}

extension ConversationListViewController.ViewModel {
    func updateNoConversationVisibility(animated: Bool = true) {
        if !ZMConversationList.hasConversations {
            viewController?.showNoContactLabel(animated: animated)
        } else {
            viewController?.hideNoContactLabel(animated: animated)
        }
    }

    func updateObserverTokensForActiveTeam() {
        if let userSession = ZMUserSession.shared() {
            allConversationsObserverToken = ConversationListChangeInfo.add(observer:self, for: ZMConversationList.conversationsIncludingArchived(inUserSession: userSession), userSession: userSession)
            
            connectionRequestsObserverToken = ConversationListChangeInfo.add(observer: self, for: ZMConversationList.pendingConnectionConversations(inUserSession: userSession), userSession: userSession)
        }
    }

    func updateArchiveButtonVisibility() {
        viewController?.updateArchiveButtonVisibilityIfNeeded(showArchived: ZMConversationList.hasArchivedConversations)
    }

    var hasArchivedConversations: Bool {
        return conversationListType.hasArchivedConversations
    }
}
