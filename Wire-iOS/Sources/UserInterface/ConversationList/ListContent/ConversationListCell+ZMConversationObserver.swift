

import Foundation

extension ConversationListCell: ZMConversationObserver {
    public func conversationDidChange(_ change: ConversationChangeInfo) {
        guard let conversation = conversation,
            change.conversation == conversation,
            change.isArchivedChanged ||
            change.placeTopStatusChanged ||
            change.conversationListIndicatorChanged ||
            change.nameChanged ||
            change.unreadCountChanged ||
            change.connectionStateChanged ||
            change.mutedMessageTypesChanged ||
            change.messagesChanged ||
            change.notDisturbStatusChanged
            else { return }

        updateAppearance()
    }
}
