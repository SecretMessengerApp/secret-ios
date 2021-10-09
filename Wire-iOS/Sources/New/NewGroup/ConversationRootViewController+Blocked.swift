

import Foundation

extension ConversationRootViewController {
    
    func handleIfBlocked() {
        guard self.conversation.conversationType == .hugeGroup else {
            return
        }
        
        let isBlockedViewCreated = self.blockedAlertView != nil
        let isBlockedViewHidden = self.blockedAlertView?.isHidden
        
        switch (conversation.blocked, isBlockedViewCreated, isBlockedViewHidden) {
        case (true, true, _):
            self.blockedAlertView?.isHidden = false
        case (true, false, _):
            createBlockedView()
        case (false, true, _):
            self.blockedAlertView?.isHidden = true
        default: break
        }
    }
    
    func createBlockedView() {
        
        let alertTitle = "conversation.group.report.blockAlertTitle".localized

        var confirmAction: AlertView.ActionType
        var cancelAction: AlertView.ActionType? = nil
        if self.conversation.creator.isSelfUser {
            confirmAction = AlertView.ActionType.confirm(("conversation.group.report.applyUnblocking".localized, {[weak self] in
                guard let cid = self?.conversation.remoteIdentifier?.transportString() else { return }
                self?.present(ReportInfoViewController(type: .unblock, cid: cid).wrapInNavigationController(), animated: true, completion: {
                    self?.backToConversationList()
                })
            }))
            cancelAction = AlertView.ActionType.cancel(("general.ok".localized, {[weak self] in
                self?.backToConversationList()
            }))
        } else {
            confirmAction = AlertView.ActionType.confirm(("general.ok".localized, {[weak self] in
                self?.backToConversationList()
            }))
        }
        
        let paraph = NSMutableParagraphStyle()
        paraph.lineSpacing = 15
        let title = NSAttributedString(
            string: alertTitle,
            attributes: [NSAttributedString.Key.font: UIFont(16, .regular),
                         NSAttributedString.Key.foregroundColor: UIColor.black,
                         NSAttributedString.Key.paragraphStyle: paraph])
        self.blockedAlertView = AlertView(with: title, topSpace: 20, bottomSpace: 20, confirm: confirmAction, cancel: cancelAction, needRemove: false)
        self.view.addSubview(self.blockedAlertView!)
        self.blockedAlertView!.frame = self.view.bounds
        self.view.bringSubviewToFront(self.blockedAlertView!)
    }
    
}
