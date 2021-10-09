//
//  ConversationViewController+UserProfile.swift
//  Wire-iOS
//

import Foundation

extension ConversationViewController: UserProfileViewControllerDelegate {

    func wantToCreateConversationWithName(_ name: String, users: Set<ZMUser>) {
        let conversationCreation = {
            var newConversation: ZMConversation?
            ZMUserSession.shared()?.enqueueChanges({
                newConversation = ZMConversation.insertGroupConversation(
                    intoUserSession: ZMUserSession.shared()!,
                    withParticipants: Array.init(users),
                    name: name,
                    in: ZMUser.selfUser()?.team,
                    allowGuests: false)
            }, completionHandler: {[weak self] in
                guard newConversation != nil else { return }
                self?.zClientViewController.select(conversation: newConversation!, focusOnView: true, animated: true)
            })
        }

        if nil != self.presentedViewController {
            self.dismiss(animated: true, completion: conversationCreation)
        } else {
            conversationCreation()
        }
    }
    
    func wantsToNavigateToConversation(_ conversation: ZMConversation) {
        dismiss(animated: true) {
            ZClientViewController.shared?.load(conversation, scrollTo: nil, focusOnView: true, animated: true)
        }
    }
}
