
import Foundation
import WireDataModel

extension ConversationInputBarViewController: ZMTypingChangeObserver {
    func typingDidChange(conversation: ZMConversation, typingUsers: Set<ZMUser>) {
        updateTypingIndicator()
    }

    func updateTypingIndicator() {
        let otherTypingUsers = conversation.typingUsers()?
            .compactMap { $0 as? ZMUser }
            .filter { !$0.isSelfUser }
            ?? []
        updateTypingIndicator(typingUsers: otherTypingUsers)
    }
    
    func updateTypingIndicator(typingUsers: [ZMUser]) {
        let shouldHide = typingUsers.isEmpty
        if !shouldHide {
            typingIndicatorView.typingUsers = typingUsers
            typingIndicatorView.layoutIfNeeded()
        }

        typingIndicatorView.setHidden(shouldHide, animated: !shouldHide)
    }
}

