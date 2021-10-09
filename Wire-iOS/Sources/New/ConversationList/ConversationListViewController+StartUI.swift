//
// Secret
// ConversationListViewController+StartUI.swift
//
// Created by 王杰 on 2019/10/15.
//



import Foundation

extension ConversationListViewController: StartUIDelegate {
    
    func startUI(_ startUI: StartUIViewController, didSelect users: Set<ZMUser>) {
        guard users.count > 0 else {return}
        self.withcon
    }
    
    func startUI(_ startUI: StartUIViewController, didSelect conversation: ZMConversation) {
        
    }
    
    func startUI(_ startUI: StartUIViewController, createConversationWith users: Set<ZMUser>, name: String, allowGuests: Bool, enableReceipts: Bool) {
        
    }
}

