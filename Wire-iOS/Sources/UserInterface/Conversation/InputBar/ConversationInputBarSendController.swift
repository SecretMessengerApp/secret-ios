
import WireDataModel
import UIKit

final class ConversationInputBarSendController: NSObject {
    
    let conversation: ZMConversation
    
    var isNeedAssistantBotReply: Bool = false

    init(conversation: ZMConversation) {
        self.conversation = conversation
        super.init()
    }

    func sendMessage(
        withImageData imageData: Data,
        isOriginal: Bool,
        completion completionHandler: Completion? = nil
    ) {
        ZMUserSession.shared()?.enqueueChanges({
            self.conversation.append(imageFromData:imageData, isOriginal: isOriginal)
        }, completionHandler: {
            WRTools.playSendMessageSound()
            completionHandler?()
            Analytics.shared().tagMediaActionCompleted(.photo, inConversation: self.conversation)
        })
    }
    
    func sendTextMessage(
        _ text: String,
        mentions: [Mention],
        replyingTo message: ZMConversationMessage?,
        isMarkDown: Bool = false
    ) {
        ZMUserSession.shared()?.enqueueChanges({
            let shouldFetchLinkPreview = !Settings.disableLinkPreviews
            let message = self.conversation.append(
                text: text,
                mentions: mentions,
                replyingTo: message,
                fetchLinkPreview: shouldFetchLinkPreview,
                isMarkDown: isMarkDown
            )
            if self.conversation.conversationType == .oneOnOne && message?.isEphemeral == false {
                if ![.closed, .AI].contains(self.conversation.autoReplyFromOther) {
                    (message as? ZMClientMessage)?.isNeedReply = true
                }
                if self.conversation.autoReplyFromOther == .AI || self.conversation.autoReply == .AI {
                    (message as? ZMClientMessage)?.isNeedUpload = true
                }
            }
            // BOT:TODO
//        if (self.conversation.conversationType == ZMConversationTypeHugeGroup) {
            (message as? ZMClientMessage)?.isNeedAssistantBotReply = self.isNeedAssistantBotReply
//        }
            self.conversation.draftMessage = nil
        }, completionHandler: {
            WRTools.playSendMessageSound()
            Analytics.shared().tagMediaActionCompleted(.text, inConversation: self.conversation)
        })
    }
    
    func sendTextMessage(
        _ text: String,
        mentions: [Mention],
        withImageData data: Data
    ) {
        let shouldFetchLinkPreview = !Settings.disableLinkPreviews
        
        ZMUserSession.shared()?.enqueueChanges({
            self.conversation.append(
                text: text,
                mentions: mentions,
                replyingTo: nil,
                fetchLinkPreview: shouldFetchLinkPreview
            )
            self.conversation.append(imageFromData: data)
            self.conversation.draftMessage = nil
        }, completionHandler: {
            WRTools.playSendMessageSound()
            Analytics.shared().tagMediaActionCompleted(.photo, inConversation: self.conversation)
            Analytics.shared().tagMediaActionCompleted(.text, inConversation: self.conversation)
        })
    }
}
