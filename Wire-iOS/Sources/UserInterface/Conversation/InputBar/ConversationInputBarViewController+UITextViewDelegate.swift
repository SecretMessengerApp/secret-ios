
import Foundation
import UIKit

// MARK: SplitViewController reveal

extension CharacterSet {
    static var newlinesAndTabulation = CharacterSet(charactersIn: "\r\n\t")
}

extension ConversationInputBarViewController {
    func hideLeftView() {
        guard self.isIPadRegularPortrait(device: UIDevice.current, application: UIApplication.shared) else { return }
        guard let splitViewController = wr_splitViewController, splitViewController.isLeftViewControllerRevealed else { return }

        splitViewController.setLeftViewControllerRevealed(false, animated: true)
    }
}

extension ConversationInputBarViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        // In case the conversation isDeleted
        if conversation.managedObjectContext == nil {
            return
        }

        conversation.setIsTyping(textView.text.count > 0)

        triggerMentionsIfNeeded(from: textView)
        updateRightAccessoryView()
    }

    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return textAttachment.image == nil
    }

    var isMentionsViewKeyboardCollapsed: Bool {
        /// press tab or enter to insert mention if iPhone keyboard is collapsed
        if let isKeyboardCollapsed = mentionsView?.isKeyboardCollapsed {
            return isKeyboardCollapsed
        } else {
            return false
        }
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // send only if send key pressed
        if textView.returnKeyType == .send && (text == "\n") {
            if UIDevice.current.type == .iPad,
                canInsertMention {
                insertBestMatchMention()
            }
            else {
                inputBar.textView.autocorrectLastWord()
                sendText()
            }
            return false
        }

        // insert mention if return or tab key is pressed and mention view is visible
        if text.count == 1,
            text.containsCharacters(from: CharacterSet.newlinesAndTabulation),
            canInsertMention,
            UIDevice.current.type == .iPad || isMentionsViewKeyboardCollapsed {
            
            insertBestMatchMention()
            return false
        }

        // we are deleting text one by one
        if text == "" && range.length == 1 {
            if let cursor = textView.selectedTextRange, let deletionStart = textView.position(from: cursor.start, offset: -1) {
                if cursor.start == cursor.end && // We have only caret, no selected text
                    textView.attributedText.containsAttachments(in: range) { // Text to be deleted has text attachment
                    textView.selectedTextRange = textView.textRange(from: deletionStart, to: cursor.start) // Select the text to be deleted and ignore the backspace
                    return false
                }
            }
        }

        inputBar.textView.respondToChange(text, inRange: range)
        return true
    }

    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard mode != .audioRecord else { return true }
        triggerMentionsIfNeeded(from: textView)
        return delegate?.conversationInputBarViewControllerShouldBeginEditing(self) ?? true
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        updateAccessoryViews()
        updateNewButtonTitleLabel()
        hideLeftView()
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return delegate?.conversationInputBarViewControllerShouldEndEditing(self) ?? true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count > 0 {
            conversation.setIsTyping(false)
        }
        
        guard let textView = textView as? MarkdownTextView else { preconditionFailure("Invalid textView class") }
        let draft = draftMessage(from: textView)
        delegate?.conversationInputBarViewControllerDidComposeDraft(message: draft)
    }
}

