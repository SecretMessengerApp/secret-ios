

import Foundation
import WireDataModel
import UIKit

fileprivate typealias ConversationCreatedBlock = (ZMConversation?) -> Void

extension ConversationListViewController.ViewModel: StartUIDelegate {
    
    func startUI(_ startUI: StartUIViewController, didSelect user: UserType) {
        oneToOneConversationWithUser(user) { conversation in
            guard let conversation = conversation else { return }
            ZClientViewController.shared?.select(conversation: conversation, focusOnView: true, animated: true)
        }
    }

    func startUI(_ startUI: StartUIViewController, didSelect conversation: ZMConversation) {
        startUI.dismissIfNeeded(animated: true) {
            ZClientViewController.shared?.select(conversation: conversation, focusOnView: true, animated: true)
        }
    }

    func startUI(_ startUI: StartUIViewController,
                 createConversationWith users: UserSet,
                 name: String,
                 allowGuests: Bool,
                 enableReceipts: Bool) {

        let createConversationClosure = {
            self.createConversation(withUsers: users, name: name, allowGuests: allowGuests, enableReceipts: enableReceipts)
        }

        (viewController as? UIViewController)?.dismissIfNeeded(completion: createConversationClosure)
    }
    
    
    
    /// Create a new conversation or open existing 1-to-1 conversation
    ///
    /// - Parameters:
    ///   - user: the user which we want to have a 1-to-1 conversation with
    ///   - onConversationCreated: a ConversationCreatedBlock which has the conversation created
    private func oneToOneConversationWithUser(_ user: UserType, callback onConversationCreated: @escaping ConversationCreatedBlock) {
        
        guard let userSession = ZMUserSession.shared() else { return }
        
        viewController?.setState(.conversationList, animated:true) {
            var oneToOneConversation: ZMConversation? = nil
            userSession.enqueueChanges ({
                oneToOneConversation = user.oneToOneConversation
            }) {
                delay(0.3) {
                    onConversationCreated(oneToOneConversation)
                }
            }
        }
    }
    
    private func createConversation(withUsers users: UserSet?, name: String?, allowGuests: Bool, enableReceipts: Bool) {
        guard let users = users, let userSession = ZMUserSession.shared() else { return }
        
        var conversation: ZMConversation! = nil
        
        userSession.enqueueChanges({
            conversation = ZMConversation.insertGroupConversation(
                into: userSession.managedObjectContext,
                withParticipants: users.compactMap { $0 as? ZMUser },
                name: name,
                in: ZMUser.selfUser()?.team,
                allowGuests: allowGuests
            )
        }) {
            delay(0.3) {
                ZClientViewController.shared?.select(conversation: conversation, focusOnView: true, animated: true)
            }
        }
    }
}
