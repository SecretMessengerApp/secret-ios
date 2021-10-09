
import Foundation
import UIKit

extension ConversationInputBarViewController {
    
    func sendText() {
        let (text, mentions) = inputBar.textView.preparedText
        let quote = quotedMessage
        guard !showAlertIfTextIsTooLong(text: text) else { return }

        if inputBar.isEditing, let message = editingMessage {
            guard message.textMessageData?.messageText != text else { return }

            delegate?.conversationInputBarViewControllerDidFinishEditing(message, withText: text, mentions: mentions)
            editingMessage = nil
            updateWritingState(animated: true)
        } else {
            clearInputBar()
            delegate?.conversationInputBarViewControllerDidComposeText(text: text, mentions: mentions, replyingTo: quote)
        }

        dismissMentionsIfNeeded()
    }

    func showAlertIfTextIsTooLong(text: String) -> Bool {
        guard text.count > SharedConstants.maximumMessageLength else { return false }

        let alert = UIAlertController.alertWithOKButton(
            title: "conversation.input_bar.message_too_long.title".localized,
            message: "conversation.input_bar.message_too_long.message".localized(args: SharedConstants.maximumMessageLength)
        )

        present(alert, animated: true)

        return true
    }
}
