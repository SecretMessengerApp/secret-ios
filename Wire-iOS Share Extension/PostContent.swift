
import Foundation
import UIKit
import WireShareEngine
import MobileCoreServices


/// Content that is shared on a share extension post attempt
final class PostContent {
    
    /// Conversation to post to
    var target: Conversation? = nil

    fileprivate var sendController: SendController?

    var sentAllSendables: Bool {
        guard let sendController = sendController else { return false }
        return sendController.sentAllSendables
    }
    
    /// List of attachments to post
    var attachments : [NSItemProvider]
    
    init(attachments: [NSItemProvider]) {
        self.attachments = attachments
    }

}


// MARK: - Send attachments

/// What to do when a conversation that was verified degraded (we discovered a new
/// non-verified client)
enum DegradationStrategy {
    case sendAnyway
    case cancelSending
}


extension PostContent {

    /// Send the content to the selected conversation
    func send(text: String, sharingSession: SharingSession, stateCallback: @escaping SendingStateCallback) {
        let conversation = target!
        sendController = SendController(text: text, attachments: attachments, conversation: conversation, sharingSession: sharingSession)

        let allMessagesEnqueuedGroup = DispatchGroup()
        allMessagesEnqueuedGroup.enter()

        let conversationObserverToken = conversation.add { change in
            // make sure that we notify only when we are done preparing all the ones to be sent
            allMessagesEnqueuedGroup.notify(queue: .main, execute: {
                let degradationStrategy: DegradationStrategyChoice = {
                    switch $0 {
                    case .sendAnyway:
                        conversation.acknowledgePrivacyWarning(withResendIntent: true)
                    case .cancelSending:
                        conversation.acknowledgePrivacyWarning(withResendIntent: false)
                        stateCallback(.done)
                    }
                }
                stateCallback(.conversationDidDegrade((change.users, degradationStrategy)))
            })
        }

        // We intercept and forward the state callback to start listening for 
        // conversation degradation and to tearDown the observer once done.
        sendController?.send {
            switch $0 {
            case .done: conversationObserverToken.tearDown()
            case .startingSending: allMessagesEnqueuedGroup.leave()
            default: break
            }

            stateCallback($0)
        }
    }

    func cancel(completion: @escaping () -> Void) {
        sendController?.cancel(completion: completion)
    }

}
