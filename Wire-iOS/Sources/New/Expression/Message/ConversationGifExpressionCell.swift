
import Foundation
import SDWebImage
import FLAnimatedImage

class ConversationExpressionGifCell: ConversationExpressionCell, ConversationMessageCell {
    
    struct Configuration {
        let message: ZMConversationMessage
    }
    
    private var animationImageView = FLAnimatedImageView()
    
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
            animationImageView.widthAnchor.constraint(equalToConstant: conversationGifExpressionWidth),
            animationImageView.heightAnchor.constraint(equalToConstant: conversationGifExpressionWidth),
            leadConstraint!,
            trailConstraint!
            ])
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
        message = object.message
        if let jsonMessageText = message?.jsonTextMessageData?.jsonMessageText {
            let jsonMessage = ConversationJSONMessage(jsonMessageText)
            expression = jsonMessage.expression
            guard let rawurl = jsonMessage.expression?.url, let url = URL(string: rawurl) else {return}
            animationImageView.sd_setImage(with: url, completed: nil)
        }
        updateConstraint()
    }
}


class ConversationExpressionGifCellDescription: ConversationMessageCellDescription {
    
    typealias View = ConversationExpressionGifCell
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
        self.configuration = View.Configuration(message: message)
    }
    
}

