

import Foundation
import Cartography
import SwiftyJSON

class ConversationConfirmAddContactCell: UIView, ConversationMessageCell {
    
    struct Configuration: Equatable {
        static func == (lhs: ConversationConfirmAddContactCell.Configuration, rhs: ConversationConfirmAddContactCell.Configuration) -> Bool {
            return lhs.jsonText == rhs.jsonText
        }
        
        let message: ZMConversationMessage
        let jsonText: String
    }
    
    weak var message: ZMConversationMessage?
    
    weak var delegate: ConversationMessageCellDelegate?
    
    var isSelected: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        createConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.confirmBtn)
    }
    
    private func createConstraints() {
        constrain(self, titleLabel, confirmBtn) { (messageV, titleLab, confirmbtn) in
            
            titleLab.centerX == messageV.centerX
            titleLab.top == messageV.top
            titleLab.height >= 20
            
            confirmbtn.top == titleLab.bottom
            confirmbtn.centerX == titleLab.centerX
            confirmbtn.bottom == messageV.bottom
        }
    }
    
    func configure(with object: Configuration, animated: Bool) {
        message = object.message
        let originStr = object.jsonText
        let dictionary = JSON.init(parseJSON: originStr)
        if let inviter = dictionary["msgData"]["name"].string,
            let nums = dictionary["msgData"]["nums"].int {
            self.titleLabel.text = "conversation.groupinvite.invite".localized(args: inviter, "\(nums)")
        }
        
        if let inviter = dictionary["msgData"]["type"].int, inviter == 2 { 
            self.confirmBtn.isEnabled = false
            self.confirmBtn.setTitle("conversation.groupinvite.done".localized, for: UIControl.State.normal)
            self.confirmBtn.setTitleColor(.dynamic(scheme: .note), for: UIControl.State.normal)
        } else {
            self.confirmBtn.isEnabled = true
            self.confirmBtn.setTitle("conversation.groupinvite.do".localized, for: UIControl.State.normal)
            self.confirmBtn.setTitleColor(UIColor(hex: 0x009dff), for: UIControl.State.normal)
        }

    }
    
    @objc func confirmAction() {
        guard let `message` = message else {return}
        self.delegate?.conversationCellConfirmNewJsonMessage?(message: message)
    }
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .dynamic(scheme: .note)
        label.font = UIFont(12, .regular)
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    fileprivate lazy var confirmBtn: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont(12, .regular)
        btn.setTitleColor(UIColor(hex: 0x009dff), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return btn
    }()
    
}

class ConversationConfirmAddContactCellDescription: ConversationMessageCellDescription {
    
    typealias View = ConversationConfirmAddContactCell
    let configuration: View.Configuration
    
    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 8
    
    let isFullWidth: Bool = false
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = true
    
    let accessibilityIdentifier: String? = "ConfirmAddContactCell"
    let accessibilityLabel: String? = nil
    
    init(message: ZMConversationMessage) {
        self.message = message
        self.configuration = View.Configuration(message: message, jsonText: message.jsonTextMessageData?.jsonMessageText ?? "")
    }
    
    func isConfigurationEqual(with other: Any) -> Bool {
        guard let otherDescription = other as? ConversationConfirmAddContactCellDescription else { return false }
        return configuration == otherDescription.configuration
    }
}

