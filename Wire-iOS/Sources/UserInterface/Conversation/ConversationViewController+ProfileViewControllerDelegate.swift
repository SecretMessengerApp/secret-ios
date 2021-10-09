

extension ConversationViewController: ProfileViewControllerDelegate {
    
    func profileViewController(
        _ controller: ProfileViewController?,
        wantsToNavigateTo conversation: ZMConversation
    ) {
        dismiss(animated: true) {
            self.zClientViewController.select(conversation: conversation, focusOnView: true, animated: true)
        }
    }
    
    func profileViewController(
        _ controller: ProfileViewController?,
        wantsToCreateConversationWithName name: String?,
        users: UserSet
    ) {
        guard let userSession = ZMUserSession.shared() else { return }
        
        let conversationCreation = { [weak self] in
            var newConversation: ZMConversation! = nil
            
            userSession.enqueueChanges({
                newConversation = ZMConversation.insertGroupConversation(
                    into: userSession.managedObjectContext,
                    withParticipants: users.compactMap { $0 as? ZMUser },
                    name: name,
                    in: ZMUser.selfUser().team
                )
            }, completionHandler: {
                self?.zClientViewController.select(
                    conversation: newConversation,
                    focusOnView: true,
                    animated: true
                )
            })
        }
        
        if nil != presentedViewController {
            dismiss(animated: true, completion: conversationCreation)
        } else {
            conversationCreation()
        }
    }
}


extension ConversationViewController {
    
    func createUserDetailViewController() -> UIViewController {
        guard let user = (conversation.firstActiveParticipantOtherThanSelf ?? conversation.connectedUser) else {
            fatal("no firstActiveParticipantOtherThanSelf!")
        }
        return UserDetailViewControllerFactory.createUserDetailViewController(
            user: user,
            conversation: conversation,
            profileViewControllerDelegate: self,
            viewControllerDismisser: self
        )
    }
}
