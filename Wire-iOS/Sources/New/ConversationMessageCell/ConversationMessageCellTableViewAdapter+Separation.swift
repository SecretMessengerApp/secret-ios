

extension ConversationMessageCellTableViewAdapter {
    
    func separateMessageSender() {
        
        if let isSystem = cellDescription?.message?.isSystem, isSystem {
            return
        }

        let isFromSelf = cellDescription?.message?.sender?.isSelfUser ?? false
        if isFromSelf {
            self.leftMargin = Float(UIView.conversationLayoutMarginsForSelf.left)
            self.rightMargin = Float(UIView.conversationLayoutMarginsForSelf.right)
        } else {
            if let conversationType = cellDescription?.message?.conversation?.conversationType, conversationType == .oneOnOne {
                self.leftMargin = Float(UIView.conversationLayoutMarginsForOtherInOneToOne.left)
                self.rightMargin = Float(UIView.conversationLayoutMarginsForOtherInOneToOne.right)
            } else {
                self.leftMargin = Float(UIView.conversationLayoutMarginsForOtherInGroup.left)
                self.rightMargin = Float(UIView.conversationLayoutMarginsForOtherInGroup.right)
            }
        }
    }
    
}
