
import Foundation
import Cartography

internal class TextSearchResultCell: UITableViewCell {
    fileprivate let messageTextLabel = SearchResultLabel()
    fileprivate let footerView = TextSearchResultFooter()
    fileprivate let userImageViewContainer = UIView()
    fileprivate let userImageView = UserImageView()
    fileprivate let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.dynamic(scheme: .separator)
        return view
    }()
    fileprivate var observerToken: Any?
    public let resultCountView: RoundedTextBadge = {
        let roundedTextBadge = RoundedTextBadge()
        roundedTextBadge.backgroundColor = .lightGraphite

        return roundedTextBadge
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        userImageView.userSession = ZMUserSession.shared()
        userImageView.initialsFont = .systemFont(ofSize: 11, weight: .light)

        accessibilityIdentifier = "search result cell"
        
        contentView.addSubview(footerView)
        selectionStyle = .none
        messageTextLabel.accessibilityIdentifier = "text search result"
        messageTextLabel.numberOfLines = 1
        messageTextLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        messageTextLabel.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        
        contentView.addSubview(messageTextLabel)
        
        userImageViewContainer.addSubview(userImageView)
        
        contentView.addSubview(userImageViewContainer)
        
        contentView.addSubview(separatorView)
        
        resultCountView.textLabel.accessibilityIdentifier = "count of matches"
        contentView.addSubview(resultCountView)
        
        constrain(userImageView, userImageViewContainer) { userImageView, userImageViewContainer in
            userImageView.height == 24
            userImageView.width == userImageView.height
            userImageView.center == userImageViewContainer.center
        }
        
        constrain(contentView, footerView, messageTextLabel, userImageViewContainer, resultCountView) { contentView, footerView, messageTextLabel, userImageViewContainer, resultCountView in
            userImageViewContainer.leading == contentView.leading
            userImageViewContainer.top == contentView.top
            userImageViewContainer.bottom == contentView.bottom
            userImageViewContainer.width == 48
            
            messageTextLabel.top == contentView.top + 10
            messageTextLabel.leading == userImageViewContainer.trailing
            messageTextLabel.trailing == resultCountView.leading - 16
            messageTextLabel.bottom == footerView.top - 4
            
            footerView.leading == userImageViewContainer.trailing
            footerView.trailing == contentView.trailing - 16
            footerView.bottom == contentView.bottom - 10
            
            resultCountView.trailing == contentView.trailing - 16
            resultCountView.centerY == contentView.centerY
            resultCountView.height == 20
            resultCountView.width >= 24
        }
        
        constrain(contentView, separatorView, userImageViewContainer) { contentView, separatorView, userImageViewContainer in
            separatorView.leading == userImageViewContainer.trailing
            separatorView.trailing == contentView.trailing
            separatorView.bottom == contentView.bottom
            separatorView.height == CGFloat.hairline
        }

        textLabel?.textColor = .from(scheme: .background)
        textLabel?.font = .smallSemiboldFont
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        message = .none
        queries = []
    }
    
    private func updateTextView() {
        guard let message = message else {
            return
        }

        if message.isObfuscated {
            let obfuscatedText = messageTextLabel.text?.obfuscated() ?? ""
            messageTextLabel.configure(with: obfuscatedText, queries: [])
            messageTextLabel.isObfuscated = true
            return
        }

        guard let text = message.textMessageData?.messageText else {
            return
        }

        messageTextLabel.configure(with: text, queries: queries)
        
        let totalMatches = messageTextLabel.estimatedMatchesCount
        
        resultCountView.isHidden = totalMatches <= 1
        resultCountView.textLabel.text = "\(totalMatches)"
        resultCountView.updateCollapseConstraints(isCollapsed: false)
    }
    
    public func configure(with newMessage: ZMConversationMessage, queries newQueries: [String]) {
        message = newMessage
        queries = newQueries
        
        userImageView.user = newMessage.sender
        footerView.message = newMessage
        if let userSession = ZMUserSession.shared() {
            observerToken = MessageChangeInfo.add(observer: self,
                                                  for: newMessage,
                                                  userSession: userSession)
        }
        
        updateTextView()
    }
    
    var message: ZMConversationMessage? = .none
    var queries: [String] = []
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool)  {
        super.setHighlighted(highlighted, animated: animated)
        
        let backgroundColor = UIColor.dynamic(scheme: .background)
        let foregroundColor = UIColor.dynamic(scheme: .title)
        
        contentView.backgroundColor = highlighted ? backgroundColor.mix(foregroundColor, amount: 0.1) : backgroundColor
    }
}

extension TextSearchResultCell: ZMMessageObserver {
    func messageDidChange(_ changeInfo: MessageChangeInfo) {
        updateTextView()
    }
}
