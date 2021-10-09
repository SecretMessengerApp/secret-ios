//
//  ConversationJsonMessageCellClickProtocol.swift
//  Wire-iOS
//

import Foundation


@objc protocol ConversationJsonMessageCellClickProtocol {
    
    @objc func conversationJsonMessageCellClickAction()
}

extension ConversationJsonMessageCellClickProtocol {
    
    func addTapAction(in containerView: UIView) {
        let tapAction = UITapGestureRecognizer.init(target: self, action: #selector(conversationJsonMessageCellClickAction))
        containerView.isUserInteractionEnabled = true
        containerView.addGestureRecognizer(tapAction)
    }
}
