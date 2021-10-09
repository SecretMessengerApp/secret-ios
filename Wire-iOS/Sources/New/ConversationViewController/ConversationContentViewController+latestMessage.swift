

import Cartography

extension ConversationContentViewController {
    
    func createToLatestMsgBtn() {
        guard toLatestMessageButton == nil else { return }
        let btn = IconButton()
        btn.cornerRadius = 17
        btn.backgroundColor = .dynamic(scheme: .secondaryBackground)
        btn.addTarget(self, action: #selector(toLatestMessageButtonClicked), for: .touchUpInside)
        btn.isHidden = true
        btn.titleLabel?.font = UIFont(15, .medium)
        btn.setTitle("conversation_content_vc_scroll_latest_msg".localized, for: .normal)
        btn.setTitleColor(.dynamic(scheme: .title), for: .normal)
        btn.setIcon(.downArrow, size: .tiny, for: .normal)
        btn.setIconColor(scheme: .iconNormal, for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 125, bottom: 0, right: 0)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: .hairline, height: .hairline)
        btn.layer.shadowOpacity = 0.6
        toLatestMessageButton = btn
        view.addSubview(btn)
        constrain(btn, tableView) { (button, view) in
            button.width == 150
            button.height == 34
            button.centerX == view.centerX
            button.bottom == view.bottom - 16
        }
    }
    
    @objc private func toLatestMessageButtonClicked() {
        if dataSource.fetchOffset > 0 {
            if let lastMessage = self.conversation.lastVisibleMessage {
                self.scroll(to: lastMessage)
                self.tableView.scrollToBottomNoAnimation()
                latestMessageButtonShouldHide(true)
            }
        } else {
            self.tableView.scrollToBottomNoAnimation()
            latestMessageButtonShouldHide(true)
        }
    }
    
    func latestMessageButtonShouldHide(_ isHidden: Bool) {
        if toLatestMessageButton?.isHidden == isHidden { return } 
        let duration = isHidden ? 0.0 : 0.3
        UIView.animate(withDuration: duration) {
            self.toLatestMessageButton?.isHidden = isHidden
        }
    }
    
    func showOrHiddenLatestMessageButton() {
        if dataSource.fetchOffset > 0 {
            self.latestMessageButtonShouldHide(false)
        } else {
            let bottomOffset = tableView.contentOffset.y
            self.latestMessageButtonShouldHide(bottomOffset < 2000)
        }
    }
    
}
