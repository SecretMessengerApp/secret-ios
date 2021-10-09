

import Foundation


private let endEditingNotificationName = "ConversationInputBarViewControllerShouldEndEditingNotification"


extension ConversationInputBarViewController {
    
    func editMessage(_ message: ZMConversationMessage) {
        guard let text = message.textMessageData?.messageText else { return }
        mode = .textInput
        editingMessage = message
        updateRightAccessoryView()

        inputBar.setInputBarState(.editing(originalText: text, mentions: message.textMessageData?.mentions ?? []), animated: true)
        updateIndicateButton()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(endEditingMessageIfNeeded),
            name: NSNotification.Name(rawValue: endEditingNotificationName),
            object: nil
        )
    }
    
    @objc
    func endEditingMessageIfNeeded() {
        guard let message = editingMessage else { return }
        delegate?.conversationInputBarViewControllerDidCancelEditing(message)
        editingMessage = nil
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation.draftMessage = nil
        }
        updateWritingState(animated: true)
        conversation.setIsTyping(false)

        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: endEditingNotificationName),
            object: nil
        )
    }
    
    static func endEditingMessage() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: endEditingNotificationName), object: nil)
    }

    func updateWritingState(animated: Bool) {
        guard nil == editingMessage else { return }
        inputBar.setInputBarState(.writing(ephemeral: ephemeralState), animated: animated)
        updateRightAccessoryView()
        updateIndicateButton()
    }
}


extension ConversationInputBarViewController: InputBarEditViewDelegate {

    func inputBarEditView(_ editView: InputBarEditView, didTapButtonWithType buttonType: EditButtonType) {
        switch buttonType {
        case .undo: inputBar.undo()
        case .cancel: endEditingMessageIfNeeded()
        case .confirm:
            sendText()
        }
    }
    
    func inputBarEditViewDidLongPressUndoButton(_ editView: InputBarEditView) {
        guard let text = editingMessage?.textMessageData?.messageText else { return }
        inputBar.setInputBarText(text, mentions: editingMessage?.textMessageData?.mentions ?? [])
    }

}
