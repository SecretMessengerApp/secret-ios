//
//  ConversationContentViewController+Scrolling.swift
//  Wire-iOS
//

import Foundation
import Cartography

enum ScrollViewScrollState: Int {
    case start
    case scrolling
    case end
}

extension ConversationContentViewController {
    
    func updateScrollViewWithScrollState(_ scrollState: ScrollViewScrollState) {
        switch scrollState {
        case .start:
            delegate?.conversationContentWillBeginDecelerating()
        case .end:
            delegate?.conversationContentWillEndDecelerating()
        default: break
        }
    }
}
