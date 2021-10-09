//
//  ConversationRootViewController+PageViewController.swift
//  Wire-iOS
//

import Foundation
import Cartography
import SwiftyJSON

let conversationAppId = "0x00000000000001"

extension ConversationRootViewController {

    func backToConversationList() {
        let revealed = self.wr_splitViewController?.isLeftViewControllerRevealed ?? false
        self.wr_splitViewController?.setLeftViewControllerRevealed(!revealed, animated: true, completion: nil)
    }
    
    
    @objc func groupsDismiss() {
        expandDelegate?.shouldUnexpand()
    }
}

extension ConversationRootViewController: ZMConversationObserver {
    
    public func conversationDidChange(_ changeInfo: ConversationChangeInfo) {
        
        guard !changeInfo.isinitChanges else { return }
        
        guard changeInfo.messagesChanged ||
            changeInfo.lastServiceMessageChanged ||
            changeInfo.groupCreatorChanged ||
            changeInfo.blockedChanged else { return }
        
        if changeInfo.blockedChanged {
            self.handleIfBlocked()
        }
        
    }

}
