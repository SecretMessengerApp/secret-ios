

import Foundation
import SwiftyJSON

extension ConversationContentViewController {


    var remindTypes: [RemindCategory] {
        var remindTypes: [RemindCategory] = []
        if self.getRemindViewContent(with: .announcement) != nil {
            remindTypes.append(.announcement)
        }
        if self.getRemindViewContent(with: .blockWarning) != nil {
            remindTypes = [.blockWarning]
        }
        return remindTypes
    }
    
    
    func configTopRemindViews() {
        guard self.conversation.conversationType == .group ||
            self.conversation.conversationType == .hugeGroup else {
                return
        }
        self.topRemindViews = []
        
        for type in self.remindTypes {
            self.showTopRemindView(with: type, isHidden: false)
        }
    }
    
    func changeTopRemindViewsState(_ hidden: Bool) {
        for type in self.remindTypes {
            if let view = isExistRemindView(with: type) {
                view.isHidden = hidden
            }
        }
    }
    
    /**
     * isHidden: 
     */
    func showTopRemindView(with type: RemindCategory, isHidden: Bool) {
        guard remindTypes.contains(type) else {
            return
        }
        checkRemindViewPriority(with: type, isClose: false)
        
        var remindView: ConversationRemindView? = isExistRemindView(with: type)
        if remindView == nil {
            guard getRemindViewContent(with: type) != nil else {
                return
            }
            remindView = self.createRemindView(with: type)
            topRemindViews.append(remindView!)
        }
        remindView?.isHidden = isHidden
        
        layoutRemindViews()
        if let content = getRemindViewContent(with: type) {
            remindView!.setContent(content: content)
        }
    }
    
    func closeTopRemindView(with type: RemindCategory) {
        checkRemindViewPriority(with: type, isClose: true)
        switch type {
        case .blockWarning, .announcement:
            if  let v = self.isExistRemindView(with: type),
                let idx = topRemindViews.firstIndex(of: v) {
                v.removeFromSuperview()
                topRemindViews.remove(at: idx)
            }
        }
        layoutRemindViews()
    }
    
    private func checkRemindViewPriority(with type: RemindCategory, isClose: Bool) {
        switch type {
        case .blockWarning:
           
            if isClose {
               
                self.conversation.blockWarningMessage?.isRead = true
                self.showTopRemindView(with: .announcement, isHidden: false)
            } else {
                self.closeTopRemindView(with: .announcement)
            }
        case .announcement: break
        }
    }
    

    private func layoutRemindViews() {
        var topConstraint: [NSLayoutConstraint] = []
        for type in self.remindTypes {
            if let remindV = self.isExistRemindView(with: type) {
                topConstraint.append(remindV.topAnchor.constraint(equalTo: self.view.safeTopAnchor, constant: topConstraintConstant(with: type)))
            }
        }
        NSLayoutConstraint.activate(topConstraint)
    }

    private func topConstraintConstant(with type: RemindCategory) -> CGFloat {
        switch type {
        case .blockWarning, .announcement:
            return 44
        }
    }
    private func displayHeight(with type: RemindCategory) -> CGFloat {
        switch type {
        case .blockWarning, .announcement:
            return 30
        }
    }
    
    private func getRemindViewContent(with type: RemindCategory) -> ConversationRemindView.RemindViewContent? {
        switch type {
        case .blockWarning:
            guard !self.conversation.blocked,
                let blockWarningMessage = self.conversation.blockWarningMessage, blockWarningMessage.isRead == false,
                let text = blockWarningMessage.text else {
                    return nil
            }
            return (text, nil, nil)
        case .announcement:
            guard !self.conversation.isReadAnnouncement,
                let text = self.conversation.announcement else {
                    return nil
            }
            return (text, nil, nil)
        }
    }
    
    private func createRemindView(with type: RemindCategory) -> ConversationRemindView {
        let remindView = ConversationRemindView(category: type)
        self.view.addSubview(remindView)
        self.view.bringSubviewToFront(remindView)
        NSLayoutConstraint.activate([
            remindView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            remindView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            remindView.heightAnchor.constraint(equalToConstant: displayHeight(with: type))
            ])
        remindView.delegate = self
        
        return remindView
    }
    
    private func isExistRemindView(with type: RemindCategory) -> ConversationRemindView? {
        return (self.topRemindViews as? [ConversationRemindView])?.first(where: {
            return $0.category == type
        })
    }

}


extension ConversationContentViewController: ConversationRemindViewDelegate {
    
    public func tapRemindViewTitle(remindView: ConversationRemindView) {
        switch remindView.category {

        case .announcement:
            let vc = ConversationAnnouncementViewController(conversation: self.conversation)
            self.present(vc.wrapInNavigationController(), animated: true, completion: nil)
            self.setAnnouncementRead()
            self.closeTopRemindView(with: .announcement)
        case .blockWarning:
            break
        }
    }
    
    public func cancelRemidView(remindView: ConversationRemindView) {
        switch remindView.category {
        case .announcement:
            self.setAnnouncementRead()
        case .blockWarning:
            self.setBlockWarningRead()
        }
        self.closeTopRemindView(with: remindView.category)
    }
    
    private func setAnnouncementRead() {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation.isReadAnnouncement = true
        }
    }
    
    private func setBlockWarningRead() {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation.blockWarningMessage?.isRead = true
        }
    }
    
}
