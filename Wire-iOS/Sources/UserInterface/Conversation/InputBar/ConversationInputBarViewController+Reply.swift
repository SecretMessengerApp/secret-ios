
import Foundation
import WireDataModel

extension ConversationInputBarViewController: ReplyComposingViewDelegate {

    func reply(to message: ZMConversationMessage, composingView: ReplyComposingView) {
        if let _ = replyComposingView {
            removeReplyComposingView()
        }

        addReplyComposingView(composingView)
    }

    func addReplyComposingView(_ composingView: ReplyComposingView) {
        quotedMessage = composingView.message
        self.replyComposingView = composingView
        composingView.delegate = self
    }

    func removeReplyComposingView() {
        self.quotedMessage = nil
        self.replyComposingView?.removeFromSuperview()
        self.replyComposingView = nil

        if let draft = self.conversation.draftMessage {
            let modifiedDraft = DraftMessage(text: draft.text, mentions: draft.mentions, quote: nil)
            self.delegate?.conversationInputBarViewControllerDidComposeDraft(message: modifiedDraft)
        }
    }

    func composingViewDidCancel(composingView: ReplyComposingView) {
        removeReplyComposingView()
    }

    func composingViewWantsToShowMessage(composingView: ReplyComposingView, message: ZMConversationMessage) {
        self.delegate?.conversationInputBarViewControllerWants(toShow: message)
    }

    var isReplyingToMessage: Bool {
        return quotedMessage != nil
    }

    var isEditingMessage: Bool {
        return editingMessage != nil
    }
}
