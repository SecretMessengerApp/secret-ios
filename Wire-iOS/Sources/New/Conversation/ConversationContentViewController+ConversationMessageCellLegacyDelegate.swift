
extension ConversationContentViewController {
    
    func conversationCellConfirmNewJsonMessage(message: ZMConversationMessage) {
        if message.isJsonText {
            self.clickJsonMessage(message)
        }
    }
    
    func conversationCellWantsToAddFriend(uid: String) {
        ZMUser.createUserIfNeededWithRemoteID(uid) { (user) in
            if let user = user {
                let viewController = ProfileViewController(user: user, viewer: ZMUser.selfUser(), context: ProfileViewControllerContext.profileViewer)
                self.present(viewController.wrapInNavigationController(), animated: true, completion: nil)
            }
        }
    }
    
    func conversationDidRejectAppNoticeWith(appID: String?) {
        guard let appID = appID else { return }
        delegate?.conversationContentViewController(self, presentRejectAppNoticeActionSheetWithAppID: appID)
    }
    
    func conversationCellAIEndTyping() {
        delegate?.aiEndTyping()
    }
    
    func conversationCellJoinConversation(by inviteURL: URL) {
        JoinConversationManager(inviteURL: inviteURL).checkOrPresentJoinAlert(on: self)
    }
    
    func conversationCellWantsToOpen(url: URL) {
        delegate?.conversationContentViewController(self, wantsToOpenURL: url)
    }
    
    func conversationCellWantsToMention(user: UserType) {
        delegate?.conversationContentViewController(wantToMention: user)
    }
}
