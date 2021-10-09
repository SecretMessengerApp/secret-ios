

import Foundation
import Cartography


struct CallCellViewModel {

    let icon: StyleKitIcon
    let iconColor: UIColor?
    let systemMessageType: ZMSystemMessageType
    let font, boldFont: UIFont?
    let textColor: UIColor?
    let message: ZMConversationMessage
    
    func image() -> UIImage? {
        return iconColor.map { icon.makeImage(size: .tiny, color: $0) }
    }

    func attributedTitle() -> NSAttributedString? {
        guard let systemMessageData = message.systemMessageData,
            let sender = message.sender,
            let labelFont = font,
            let labelBoldFont = boldFont,
            let labelTextColor = textColor,
            systemMessageData.systemMessageType == systemMessageType
            else { return nil }

        let senderString = string(for: sender)
        
        var called = NSAttributedString()
        
        let childs = systemMessageData.childMessages.count
        
        if systemMessageType == .missedCall {
            
            var detailKey = "missed-call"

            if [.group, .hugeGroup].contains(message.conversation?.conversationType) {
                detailKey.append(".groups")
            }
            
            called = key(with: detailKey).localized(pov: sender.pov, args: childs + 1, senderString) && labelFont
        } else {
            called = key(with: "called").localized(pov: sender.pov, args: senderString) && labelFont
        }
        
        var title = called.adding(font: labelBoldFont, to: senderString)

        if childs > 0 {
            title += " (\(childs + 1))" && labelFont
        }

        return title && labelTextColor
    }
    
        func attributedTitleForConversationList() -> NSAttributedString? {
            guard let systemMessageData = message.systemMessageData,
                let sender = message.sender,
                let labelFont = font,
                let labelBoldFont = boldFont,
                let labelTextColor = textColor,
                systemMessageData.systemMessageType == systemMessageType
                else { return nil }

            let senderString = string(for: sender)
            
            var called = NSAttributedString()
            
    //        let childs = systemMessageData.childMessages.count
            let childs = 0
            
            if systemMessageType == .missedCall {
                
                var detailKey = "missed-call"

                if [.group, .hugeGroup].contains(message.conversation?.conversationType) {
                    detailKey.append(".groups")
                }
                
                called = key(with: detailKey).localized(pov: sender.pov, args: childs + 1, senderString) && labelFont
            } else {
                called = key(with: "called").localized(pov: sender.pov, args: senderString) && labelFont
            }
            
            var title = called.adding(font: labelBoldFont, to: senderString)

//            if childs > 0 {
//                title += " (\(childs + 1))" && labelFont
//            }

            return title && labelTextColor
        }

    private func string(for user: ZMUser) -> String {
        return user.isSelfUser ? key(with: "you").localized : user.displayName(in: message.conversation)
    }

    private func key(with component: String) -> String {
        return "content.system.call.\(component)"
    }
}
