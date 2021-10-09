
import Foundation
import WireDataModel

extension ConversationContentViewController {
    
    func createReplyComposingView(for message: ZMConversationMessage) -> ReplyComposingView {
        let replyComposingView = ReplyComposingView(message: message)
        replyComposingView.translatesAutoresizingMaskIntoConstraints = false
        
        bottomContainer.addSubview(replyComposingView)
        replyComposingView.fitInSuperview()
        
        return replyComposingView
    }
}
