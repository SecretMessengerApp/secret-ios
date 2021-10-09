
import Foundation
import SDWebImage
import SSticker

class ConversationExpressionTgsCell: ConversationExpressionCell, ConversationMessageCell {
    
    struct Configuration: Equatable {
        static func == (lhs: ConversationExpressionTgsCell.Configuration, rhs: ConversationExpressionTgsCell.Configuration) -> Bool {
            return lhs.url == rhs.url
        }
        
        let message: ZMConversationMessage
        let url: String?
    }
    
    private var animationImageView = StickerAnimatedImageView(frame: .zero)
    
    weak var message: ZMConversationMessage?
    
    weak var delegate: ConversationMessageCellDelegate?
    
    var leadConstraint: NSLayoutConstraint?
    
    var trailConstraint: NSLayoutConstraint?
    
    var isSelected: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        createConstraints()
    }
    
    var selectionRect: CGRect {
        return animationImageView.frame
    }
    
    var selectionView: UIView? {
        return animationImageView
    }
    
    private func configureViews() {
        addSubview(animationImageView)
    }
    
    private func createConstraints() {
        animationImageView.translatesAutoresizingMaskIntoConstraints = false
        leadConstraint = animationImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8)
        trailConstraint = animationImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        NSLayoutConstraint.activate([
            animationImageView.topAnchor.constraint(equalTo: self.topAnchor),
            animationImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            animationImageView.widthAnchor.constraint(equalToConstant: conversationTgsExpressionWidth),
            animationImageView.heightAnchor.constraint(equalToConstant: conversationTgsExpressionWidth),
            leadConstraint!,
            trailConstraint!
            ])
    }
    
    public func clear() {
        animationImageView.clear()
    }
    
    func updateConstraint() {
        if let isself = message?.sender?.isSelfUser, isself {
            leadConstraint?.isActive = false
            trailConstraint?.isActive = true
        } else {
            leadConstraint?.isActive = true
            trailConstraint?.isActive = false
        }
    }
    
    func configure(with object: Configuration, animated: Bool) {
        guard let url = object.url, let u = URL(string: url) else { return }
        message = object.message
        if let jsonMessageText = message?.jsonTextMessageData?.jsonMessageText {
            let jsonMessage = ConversationJSONMessage(jsonMessageText)
            expression = jsonMessage.expression
        }
        animationImageView.setSecretAnimation(u, CGSize(width: conversationTgsExpressionWidth * 2, height: conversationTgsExpressionWidth * 2))
        updateConstraint()
    }
}


class ConversationExpressionTgsCellDescription: ConversationMessageCellDescription {
    
    typealias View = ConversationExpressionTgsCell
    let configuration: View.Configuration
    
    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 8
    
    let isFullWidth: Bool = false
    let supportsActions: Bool = true
    let containsHighlightableContent: Bool = true
    
    let accessibilityIdentifier: String? = "ExpressionCell"
    let accessibilityLabel: String? = nil
    
    init(message: ZMConversationMessage) {
        self.message = message
        if let jsonMessageText = message.jsonTextMessageData?.jsonMessageText {
            let jsonMessage = ConversationJSONMessage(jsonMessageText)
            self.configuration = View.Configuration(message: message, url: jsonMessage.expression?.url)
        } else {
           self.configuration = View.Configuration(message: message, url: nil)
        }
    }
    
}

