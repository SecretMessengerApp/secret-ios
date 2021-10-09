
import Foundation

class ConversationLegalHoldSystemMessageCell: ConversationIconBasedCell, ConversationMessageCell {
    
    static let legalHoldURL: URL = URL(string: "action://learn-more-legal-hold")!
    var conversation: ZMConversation?
    
    struct Configuration {
        let attributedText: NSAttributedString?
        var icon: UIImage?
        var conversation: ZMConversation?
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        lineView.isHidden = true
    }
    
    func configure(with object: Configuration, animated: Bool) {
        attributedText = object.attributedText
        imageView.image = object.icon
        conversation = object.conversation
    }
    
}

final class ConversationLegalHoldCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationLegalHoldSystemMessageCell
    let configuration: View.Configuration
    
    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 0
    
    let isFullWidth: Bool = true
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = false
    
    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil
    
    init(systemMessageType: ZMSystemMessageType, conversation: ZMConversation) {
        configuration = ConversationLegalHoldCellDescription.configuration(for: systemMessageType, in: conversation)
    }
    
    private static func configuration(for systemMessageType: ZMSystemMessageType, in conversation: ZMConversation) -> View.Configuration {
        
        let baseTemplate = "content.system.message_legal_hold"
        var template = baseTemplate
        
        if systemMessageType == .legalHoldEnabled {
            template += ".enabled"
        } else if systemMessageType == .legalHoldDisabled {
            template += ".disabled"
        }
        
        var attributedText = NSAttributedString(string: template.localized, attributes: ConversationSystemMessageCell.baseAttributes)
        
        if systemMessageType == .legalHoldEnabled {
            let learnMore = NSAttributedString(string: (baseTemplate + ".learn_more").localized.uppercased(),
                                               attributes: [.font: UIFont.mediumSemiboldFont,
                                                            .link: ConversationLegalHoldSystemMessageCell.legalHoldURL as AnyObject,
                                                            .foregroundColor: UIColor.dynamic(scheme: .title)])
            
            attributedText += " " + String.MessageToolbox.middleDot + " "
            attributedText += learnMore
        }
        
        let icon = StyleKitIcon.legalholdactive.makeImage(size: .tiny, color: .vividRed)
        
        return View.Configuration(attributedText: attributedText, icon: icon, conversation: conversation)
    }
}

extension ConversationLegalHoldSystemMessageCell {
    
    public override func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if url == ConversationLegalHoldSystemMessageCell.legalHoldURL,
            let conversation = conversation,
            let clientViewController = ZClientViewController.shared {

            LegalHoldDetailsViewController.present(in: clientViewController, conversation: conversation)
            
            return true
        }
        
        return false
    }
    
}
