

import Foundation
import Cartography

class ConversationInviteGroupMemberVerifyCell: UIView, ConversationMessageCell, ConversationJsonMessageCellClickProtocol {
    
    struct Configuration {
        let message: ZMConversationMessage
    }
    
    private let containerView = UIImageView()
    
    weak var message: ZMConversationMessage?
    
    weak var delegate: ConversationMessageCellDelegate?
    
    var isSelected: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        createConstraints()
        self.addTapAction(in: containerView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        containerView.isUserInteractionEnabled = true
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.descLabel)
        self.containerView.addSubview(self.avatarView)
        self.containerView.addSubview(self.detailBottomV)
        self.addSubview(self.containerView)
    }
    
    private func createConstraints() {
        constrain(self, containerView, titleLabel, descLabel, avatarView) {messageContentView, containerView, titleLabel, descLabel, avatarView in
            
            containerView.top == messageContentView.top
            containerView.right == messageContentView.right
            containerView.left == messageContentView.left
            containerView.height == 134
            containerView.bottom == messageContentView.bottom
            
            titleLabel.left == containerView.left + 24
            titleLabel.top == containerView.top + 15
            titleLabel.right == containerView.right - 24
            
            avatarView.top == titleLabel.bottom + 9
            avatarView.right == titleLabel.right
            avatarView.width == 55
            avatarView.height == 55
            
            descLabel.left == titleLabel.left
            descLabel.right == avatarView.left - 15
            descLabel.centerY == avatarView.centerY
            
        }
        
        constrain(containerView, avatarView, detailBottomV) { containerView, avatarView, detailBottomV in
            detailBottomV.top == avatarView.bottom + 9
            detailBottomV.bottom == containerView.bottom
            detailBottomV.height == 32
            detailBottomV.left == containerView.left
            detailBottomV.right == containerView.right
        }
    }
    
    func configure(with object: Configuration, animated: Bool) {
        message = object.message
        guard let `message` = message else {return}
        guard let originStr = message.jsonTextMessageData?.jsonMessageText  else {
            return
        }
        var senderName = message.senderName
        if message.sender?.isSelfUser ?? false {
            senderName = ""
        }
        self.titleLabel.text = "conversation.groupinvite.add.title".localized(args: senderName, message.receiverName ?? "")
        let dictionary = ConversationJSONMessage(originStr)
        let groupname = dictionary.dataDictionary?["name"] as? String
        let str = "conversation.groupinvite.add.detial".localized(args: message.senderName, message.receiverName ?? "", groupname ?? "")
        let attr = NSMutableAttributedString(string: str)
        let range = NSRange(location: 0, length: attr.length)
        attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 12), range: range)
        attr.addAttribute(.foregroundColor, value: UIColor.dynamic(scheme: .note), range: range)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 6
        attr.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)
        self.descLabel.attributedText = attr
        if let imgurl = dictionary.dataDictionary?["asset"] as? String {
            self.avatarView.image(at: URL(string: imgurl), placeholder: UIImageView.Placeholder.groupIcon)
        }
        containerView.image = message.backImage
    }
    
    func conversationJsonMessageCellClickAction() {
        guard let message = message else { return }
        delegate?.conversationCellConfirmNewJsonMessage?(message: message)
    }
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(16, .regular)
        label.textColor = UIColor.dynamic(scheme: .title)
        return label
    }()
    
    fileprivate lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(12, .regular)
        label.textColor = UIColor.dynamic(scheme: .subtitle)
        label.numberOfLines = 2
        return label
    }()
    
    fileprivate lazy var avatarView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 27.5
        view.layer.masksToBounds = true
        return view
    }()
    
    fileprivate lazy var detailBottomV: BottomView = {
        let view = BottomView()
        return view
    }()
    
    class BottomView: UIView {
        
        fileprivate lazy var arrow: UIButton = {
            let btn = IconButton()
            btn.setImage(UIImage(named: "chatDetial"), for: .normal)
            btn.setIconColor(scheme: .note, for: .normal)
            return btn
        }()
        
        fileprivate lazy var line: UIView = {
            let line = UIView()
            line.backgroundColor = .dynamic(scheme: .separator)
            return line
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            configureViews()
            createConstraints()
        }
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func configureViews() {
            [line, arrow].forEach(addSubview)
        }
        
        private func createConstraints() {
            
            constrain(self, line, arrow, block: { (view, line, arrow) in
                line.left == view.left + 24
                line.top == view.top
                line.right == view.right - 24
                line.height == .hairline
                
                arrow.left == view.left + 24
                arrow.centerY == view.centerY
                arrow.width == 15
                arrow.height == 15
            })
        }
    }
    
}

class ConversationInviteGroupMemberVerifyCellDescription: ConversationMessageCellDescription {
    
    typealias View = ConversationInviteGroupMemberVerifyCell
    let configuration: View.Configuration
    
    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 8
    
    let isFullWidth: Bool = false
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = true
    
    let accessibilityIdentifier: String? = "InviteGroupMemberVerifyCell"
    let accessibilityLabel: String? = nil
    
    init(message: ZMConversationMessage) {
        self.message = message
        self.configuration = View.Configuration(message: message)
    }
    
}
