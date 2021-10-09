//


import UIKit

class ConversationTitleView: TitleView {
    var conversation: ZMConversation
    var interactive: Bool = true
    
    init(conversation: ZMConversation, interactive: Bool = true) {
        self.conversation = conversation
        self.interactive = interactive
        super.init()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        titleColor = .dynamic(scheme: .title)
        titleColorSelected = UIColor.accent()
        titleFont = FontSpec(.medium, .semibold).font!
        accessibilityHint = "conversation_details.open_button.accessibility_hint".localized
        
        var attachments: [NSTextAttachment] = []
        
        if conversation.isUnderLegalHold {
            attachments.append(.legalHold())
        }
        
        if conversation.securityLevel == .secure {
            attachments.append(.verifiedShield())
        }
     
        super.configure(icons: attachments,
                        title: conversation.displayName,
                        interactive: self.interactive && conversation.relatedConnectionState != .sent,
                        showInteractiveIcon: true)
        
        var components: [String] = []
        components.append(conversation.displayName.localizedUppercase)
        
        if conversation.securityLevel == .secure {
            components.append("conversation.voiceover.verified".localized)
        }
        
        if conversation.isUnderLegalHold {
            components.append("conversation.voiceover.legalhold".localized)
        }
        
        if !UIApplication.isLeftToRightLayout {
            components.reverse()
        }
        
        self.accessibilityLabel = components.joined(separator: ", ")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configure()
    }
}

extension NSTextAttachment {
    static func verifiedShield() -> NSTextAttachment {
        let attachment = NSTextAttachment()
        let shield = WireStyleKit.imageOfShieldverified
        attachment.image = shield
        let ratio = shield.size.width / shield.size.height
        let height: CGFloat = 12
        attachment.bounds = CGRect(x: 0, y: -2, width: height * ratio, height: height)
        return attachment
    }
    
    static func legalHold() -> NSTextAttachment {
        let attachment = NSTextAttachment()
        let legalHold = StyleKitIcon.legalholdactive.makeImage(size: .tiny, color: .vividRed)
        attachment.image = legalHold
        let ratio = legalHold.size.width / legalHold.size.height
        let height: CGFloat = 12
        attachment.bounds = CGRect(x: 0, y: -2, width: height * ratio, height: height)
        return attachment
    }
}

