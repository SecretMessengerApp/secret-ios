
import Foundation
import Cartography


final class ConversationTextMessageCell: UIView, ConversationMessageCell, TextViewInteractionDelegate {

    struct Configuration: Equatable {
        static func == (lhs: ConversationTextMessageCell.Configuration, rhs: ConversationTextMessageCell.Configuration) -> Bool {
            return lhs.attributedText == rhs.attributedText
                && lhs.isObfuscated == rhs.isObfuscated
                && lhs.hasLink == rhs.hasLink
                && lhs.hasTranslationText == rhs.hasTranslationText
        }
        
        let attributedText: NSAttributedString
        let isObfuscated: Bool
        let hasLink: Bool
        let hasTranslationText: Bool
        let message: ZMConversationMessage
        let senderIsSelf: Bool
    }
    
    var configuration: Configuration?
    
    let messageTextView = LinkInteractionTextView()
    var isSelected: Bool = false
    let messageBackView = UIImageView()
    private let replyView = ReplyMessageView()
    private let articleView = ArticleView(withImagePlaceholder: true)
    let translateTextView = UITextView()
    private let translateLine = UIView()
    
    weak var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var menuPresenter: ConversationMessageCellMenuPresenter?
    
    private var selfLeading: NSLayoutConstraint!
    private var selfTrailing: NSLayoutConstraint!
    private var otherLeading: NSLayoutConstraint!
    private var otherTrailing: NSLayoutConstraint!
    
    private var textViewTopConstraint: NSLayoutConstraint?
    private var textViewTopHasQuoteConstraint: NSLayoutConstraint?
    
    private var textViewBottomConstraint: NSLayoutConstraint?
    private var textViewBottomHasLinkConstraint: NSLayoutConstraint?
    
    private var textViewWidthHasQuoteConstraint: NSLayoutConstraint?
    private var textViewWidthHasLinkConstraint: NSLayoutConstraint?
    
    private var replyViewRightConstraint: NSLayoutConstraint?
    private var articleViewRightConstraint: NSLayoutConstraint?
    private var translateViewRightConstraint:
        NSLayoutConstraint?
    
    private var translateViewBottomConstraint: NSLayoutConstraint?
    
    var ephemeralTimerTopInset: CGFloat {
        guard let font = messageTextView.font else {
            return 0
        }
        
        return font.lineHeight / 2
    }
    
    lazy var specificConstraints: [NSLayoutConstraint?] = {
        return [
            self.textViewTopConstraint,
            self.textViewTopHasQuoteConstraint,
            self.textViewBottomConstraint,
            self.textViewBottomHasLinkConstraint,
            self.textViewWidthHasQuoteConstraint,
            self.textViewWidthHasLinkConstraint,
            self.replyViewRightConstraint,
            self.articleViewRightConstraint,
            self.translateViewRightConstraint,
            self.translateViewBottomConstraint
        ]
    }()
    
    var selectionView: UIView? {
        return messageBackView
    }
    
    var selectionRect: CGRect {
        return messageBackView.bounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
        configureConstraints()
    }
    
    private func configureSubviews() {
        messageBackView.image = UIImage.init(named: "message_back_self")
        messageBackView.isUserInteractionEnabled = true
        addSubview(messageBackView)
        messageTextView.isEditable = false
        messageTextView.isSelectable = true
        messageTextView.backgroundColor = .clear
        messageTextView.isScrollEnabled = false
        messageTextView.textContainerInset = UIEdgeInsets.zero
        messageTextView.textContainer.lineFragmentPadding = 0
        messageTextView.isUserInteractionEnabled = true
        messageTextView.accessibilityIdentifier = "Message"
        messageTextView.accessibilityElementsHidden = false
        messageTextView.dataDetectorTypes = [.link, .address, .phoneNumber, .flightNumber, .calendarEvent, .shipmentTrackingNumber]
        messageTextView.linkTextAttributes = [.foregroundColor : UIColor.accent()]
        messageTextView.setContentHuggingPriority(.required, for: .vertical)
        messageTextView.setContentCompressionResistancePriority(.required, for: .vertical)
        messageTextView.interactionDelegate = self
        
        translateTextView.isEditable = false
        translateTextView.isSelectable = true
        translateTextView.backgroundColor = .clear
        translateTextView.isScrollEnabled = false
        translateTextView.textContainerInset = UIEdgeInsets.zero
        translateTextView.textContainer.lineFragmentPadding = 0
        translateTextView.isUserInteractionEnabled = true
        translateTextView.accessibilityIdentifier = "TranslateMessage"
        translateTextView.accessibilityElementsHidden = false
        translateTextView.dataDetectorTypes = [.link, .address, .phoneNumber, .flightNumber, .calendarEvent, .shipmentTrackingNumber]
        translateTextView.linkTextAttributes = [.foregroundColor : UIColor.accent()]
        translateTextView.setContentHuggingPriority(.required, for: .vertical)
        translateTextView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        translateLine.backgroundColor = ColorScheme.default.color(named: .separator)
        translateLine.isHidden = true
//        translateTextView.setContentHuggingPriority(.required, for: .vertical)
//        translateTextView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        if #available(iOS 11.0, *) {
            messageTextView.textDragInteraction?.isEnabled = false
            translateTextView.textDragInteraction?.isEnabled = false
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ConversationTextMessageCell.singleTap))
        tap.numberOfTapsRequired = 1
        tap.delaysTouchesBegan = true
        replyView.addGestureRecognizer(tap)
        
        messageBackView.addSubview(replyView)
        messageBackView.addSubview(messageTextView)
        messageBackView.addSubview(translateTextView)
        messageBackView.addSubview(translateLine)
        messageBackView.addSubview(articleView)
        
        articleView.delegate = self
    }
    
    private func configureConstraints() {
        constrain(self, messageBackView) { (containView, messageBackView) in
            messageBackView.top == containView.top

            otherLeading = messageBackView.left == containView.left
            otherTrailing = messageBackView.right <= containView.right
            selfLeading = messageBackView.left >= containView.left
            selfTrailing = messageBackView.right == containView.right
            selfLeading.isActive = false
            selfTrailing.isActive = false
            otherLeading.isActive = true
            otherTrailing.isActive = true

            messageBackView.bottom == containView.bottom
        }
        
        constrain(messageBackView, messageTextView, replyView, articleView, translateLine, translateTextView) { (backView, textView, replyView, articleView, translateL, translateView) in
            textViewTopConstraint = textView.top == backView.top + 6
            textView.left == backView.left + 16
            textView.right == backView.right - 16
            textViewBottomConstraint = textView.bottom == backView.bottom - 9
            textView.width >= 24
            textViewWidthHasQuoteConstraint = textView.width >= 168
            textViewWidthHasQuoteConstraint?.isActive = false
            textViewTopHasQuoteConstraint = textView.top == replyView.bottom + 6
            textViewTopHasQuoteConstraint?.isActive = false
            replyView.top == backView.top + 10
            replyView.left == textView.left
            replyViewRightConstraint = replyView.right == textView.right

            articleView.top == textView.bottom + 10
            articleView.left == textView.left
            articleViewRightConstraint = articleView.right == textView.right
            textViewWidthHasLinkConstraint = articleView.width >= 1000 ~ LayoutPriority(750)
            textViewBottomHasLinkConstraint = articleView.bottom == backView.bottom - 9
            textViewWidthHasLinkConstraint?.isActive = false
            textViewBottomHasLinkConstraint?.isActive = false
            
            translateL.height == 1
            translateL.top == textView.bottom + 7
            translateL.left == backView.left + 16
            translateL.right == backView.right - 16
            
            translateView.left == backView.left + 16
            translateViewRightConstraint = translateView.right == backView.right - 16
            translateView.top == translateL.bottom + 7
            translateView.height >= 18
            translateViewBottomConstraint = translateView.bottom == backView.bottom - 9
            translateViewBottomConstraint?.isActive = false
        }
        
    }
    
    func configure(with object: Configuration, animated: Bool) {
        self.configuration = object
        if object.isObfuscated {
            messageTextView.accessibilityIdentifier = "Obfuscated message"
        } else {
            messageTextView.accessibilityIdentifier = "Message"
        }
        let message = object.message
        
        /// messageBackView
        let senderIsSelf = object.senderIsSelf
        if senderIsSelf{
            messageBackView.image = UIImage.init(named: MessageBackImage.mineWithTail.rawValue)
        }else{
            messageBackView.image = UIImage.init(named: MessageBackImage.otherWithTail.rawValue)
        }
        
        /// Leading and Trailing
        if senderIsSelf {
            selfLeading.isActive = true
            selfTrailing.isActive = true
            otherLeading.isActive = false
            otherTrailing.isActive = false
        }else{
            selfLeading.isActive = false
            selfTrailing.isActive = false
            otherLeading.isActive = true
            otherTrailing.isActive = true
        }
        
        let enableNone = {
            [weak self] in
            guard let self = self else {return}
            self.translateLine.isHidden = true
            self.translateTextView.isHidden = true
            self.articleView.isHidden = true
            self.replyView.isHidden = true
            self.textViewTopConstraint?.isActive = true
            self.textViewBottomConstraint?.isActive = true
            self.messageTextView.attributedText = object.attributedText
            self.specificConstraints.filter { (cons) -> Bool in
                return ![
                    self.textViewTopConstraint,
                    self.textViewBottomConstraint
                ].contains(cons)
            }.forEach { $0?.isActive = false }
        }
        
        guard let textMessageData = message.textMessageData else {
            enableNone()
            return
        }
   
        let hasQuote = { () -> Bool in
            if let textMessageData = message.textMessageData,
               textMessageData.hasQuote {
                return true
            }
            return false
        }
      
        let hasLink = { () -> Bool in
            if let textMessageData = message.textMessageData,
               textMessageData.linkPreview != nil {
                return true
            }
            return false
        }
   
        let hasTranslate = { () -> (Bool, String?) in
            if let zmmessage = message as? ZMMessage, let transletText = zmmessage.translationText {
                return (true, transletText)
            }
            return (false, nil)
        }
        
        let enableLinkPreviews = { [weak self] in
            guard let self = self else {return}
            self.articleView.isHidden = false
            self.translateTextView.isHidden = true
            self.translateLine.isHidden = true
            self.replyView.isHidden = true
            self.textViewTopConstraint?.isActive = true
            self.textViewBottomHasLinkConstraint?.isActive = true
            self.textViewWidthHasLinkConstraint?.isActive = true
            self.articleViewRightConstraint?.isActive = true
            self.articleView.configure(withTextMessageData: textMessageData, obfuscated: message.isObfuscated)
            self.messageTextView.attributedText = object.attributedText
            self.translateTextView.attributedText = nil
            self.updateImageLayout(isRegular: self.traitCollection.horizontalSizeClass == .regular)
            self.specificConstraints.filter { (cons) -> Bool in
                return ![
                    self.textViewTopConstraint,
                    self.textViewBottomHasLinkConstraint,
                    self.textViewWidthHasLinkConstraint,
                    self.articleViewRightConstraint
                ].contains(cons)
            }.forEach { $0?.isActive = false }
        }
        
        let enableQuoteAndTranslation: (String) -> Void = { [weak self] transletText in
            guard let self = self else {return}
            self.replyView.isHidden = false
            self.translateLine.isHidden = false
            self.translateTextView.isHidden = false
            self.articleView.isHidden = true
            
            self.textViewTopHasQuoteConstraint?.isActive = true
            self.textViewWidthHasQuoteConstraint?.isActive = true
            
            self.replyViewRightConstraint?.isActive = true
            self.translateViewRightConstraint?.isActive = true
            self.translateViewBottomConstraint?.isActive = true
            
            self.replyView.replyMessage = textMessageData.quote
            self.replyView.isSelfMessage = senderIsSelf
            
            self.translateTextView.attributedText = NSAttributedString.formatTranslation(transletText)
            self.messageTextView.attributedText = object.attributedText
            self.specificConstraints.filter { (cons) -> Bool in
                return ![
                    self.textViewTopHasQuoteConstraint,
                    self.textViewWidthHasQuoteConstraint,
                    self.replyViewRightConstraint,
                    self.translateViewRightConstraint,
                    self.translateViewBottomConstraint
                ].contains(cons)
            }.forEach { $0?.isActive = false }
            
        }
        
        
        let enableOnlyQuoteMessage = { [weak self] in
            guard let self = self else {return}
            self.replyView.isHidden = false
            self.translateLine.isHidden = true
            self.translateTextView.isHidden = true
            self.articleView.isHidden = true
            self.textViewTopHasQuoteConstraint?.isActive = true
            self.textViewWidthHasQuoteConstraint?.isActive = true
            self.replyViewRightConstraint?.isActive = true
            self.textViewBottomConstraint?.isActive = true
            self.replyView.replyMessage = textMessageData.quote
            self.replyView.isSelfMessage = senderIsSelf
            
            self.messageTextView.attributedText = object.attributedText
            self.translateTextView.attributedText = nil
            self.specificConstraints.filter { (cons) -> Bool in
                return ![
                    self.textViewTopHasQuoteConstraint,
                    self.textViewWidthHasQuoteConstraint,
                    self.replyViewRightConstraint,
                    self.textViewBottomConstraint
                ].contains(cons)
            }.forEach { $0?.isActive = false }
        }
        
        let enableOnlyTranslation: (String) -> Void = { [weak self] text in
            guard let self = self else {return}
            self.translateLine.isHidden = false
            self.translateTextView.isHidden = false
            self.replyView.isHidden = true
            self.articleView.isHidden = true
            self.textViewTopConstraint?.isActive = true
            self.translateViewBottomConstraint?.isActive = true
            self.translateViewRightConstraint?.isActive = true
            
            self.translateTextView.attributedText = NSAttributedString.formatTranslation(text)
            self.messageTextView.attributedText = object.attributedText
            
            self.specificConstraints.filter { (cons) -> Bool in
                return ![
                    self.textViewTopConstraint,
                    self.translateViewBottomConstraint,
                    self.translateViewRightConstraint
                ].contains(cons)
            }.forEach { $0?.isActive = false }
        }
        
        if hasQuote() && hasTranslate().0 {
            enableQuoteAndTranslation((hasTranslate().1)!)
        } else if hasQuote() {
            enableOnlyQuoteMessage()
        } else if hasTranslate().0 {
            enableOnlyTranslation((hasTranslate().1)!)
        } else if hasLink() {
            enableLinkPreviews()
        } else {
            enableNone()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateImageLayout(isRegular: self.traitCollection.horizontalSizeClass == .regular)
    }
    
    func updateImageLayout(isRegular: Bool) {
        if configuration?.message.textMessageData?.linkPreviewHasImage == true {
            articleView.imageHeight = isRegular ? 250 : 150
        } else {
            articleView.imageHeight = 0
        }
    }
    
    func textView(_ textView: LinkInteractionTextView, open url: URL) -> Bool {
        // Open mention link
        if url.isMention {
            if let message = self.message, let mention = message.textMessageData?.mentions.first(where: { $0.location == url.mentionLocation }) {
                return self.openMention(mention)
            } else {
                return false
            }
        }
      
        if JoinConversationManager(inviteURL: url).isValidInviteURL {
            delegate?.conversationCellJoinConversation?(by: url)
            return true
        }
        
        if UIApplication.shared.canOpenURL(url) && (url.absoluteString.hasPrefix("http://") || url.absoluteString.hasPrefix("https://")) {
            delegate?.conversationCellWantsToOpen?(url: url)
            return true
        } else {
            HUD.text("url_action.invalid_link.title".localized)
        }
        
        return url.open()
    }

    func openMention(_ mention: Mention) -> Bool {
        delegate?.conversationMessageWantsToOpenUserDetails(self, user: mention.user, sourceView: messageTextView, frame: selectionRect)
        return true
    }

    func textViewDidLongPress(_ textView: LinkInteractionTextView) {
        if !UIMenuController.shared.isMenuVisible {
            self.menuPresenter?.showMenu()
        }
    }
    
    @objc func singleTap(tap: UITapGestureRecognizer) {
        delegate?.perform(action: .openQuote, for: message, view: self)
    }
    
}

// MARK: - Description

class ConversationTextMessageCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationTextMessageCell
    let configuration: View.Configuration

    weak var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 8

    let isFullWidth: Bool  = false
    let supportsActions: Bool = true
    let containsHighlightableContent: Bool = true

    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil
    
    init(attributedString: NSAttributedString, message: ZMConversationMessage, senderIsSelf: Bool, isObfuscated: Bool) {
        guard let msg = message as? ZMMessage else {
            configuration = View.Configuration(attributedText: attributedString, isObfuscated: isObfuscated, hasLink: message.textMessageData?.linkPreview != nil, hasTranslationText: false,  message: message, senderIsSelf: senderIsSelf)
            return
        }
        configuration = View.Configuration(attributedText: attributedString, isObfuscated: isObfuscated, hasLink: message.textMessageData?.linkPreview != nil, hasTranslationText: msg.translationText != nil,  message: message, senderIsSelf: senderIsSelf)
    }

    func makeCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueConversationCell(with: self, for: indexPath)
        cell.accessibilityCustomActions = actionController?.makeAccessibilityActions()
        cell.cellView.delegate = self.delegate
        cell.cellView.message = self.message
        cell.cellView.menuPresenter = cell
        return cell
    }
    
    func isConfigurationEqual(with other: Any) -> Bool {
        guard let otherDescription = other as? ConversationTextMessageCellDescription else { return false }

        return configuration == otherDescription.configuration
    }
}

extension ConversationTextMessageCell: ArticleViewDelegate {
    
    func articleViewWantsToOpenURL(_ articleView: ArticleView, url: URL) {
        if JoinConversationManager(inviteURL: url).isValidInviteURL {
            delegate?.conversationCellJoinConversation?(by: url)
        } else {
            delegate?.conversationCellWantsToOpen?(url: url)
        }
    }
    
}

// MARK: - Factory

extension ConversationTextMessageCellDescription {
    
    static func cells(for message: ZMConversationMessage, searchQueries: [String]) -> [AnyConversationMessageCellDescription] {
        guard let textMessageData = message.textMessageData else {
            preconditionFailure("Invalid text message")
        }
        
        var cells: [AnyConversationMessageCellDescription] = []
        
        // Refetch the link attachments if needed
        if Settings.shared[.disableLinkPreviews] != true {
            ZMUserSession.shared()?.enqueueChanges {
                message.refetchLinkAttachmentsIfNeeded()
            }
        }
        
        // Text parsing
        let attachments = message.linkAttachments ?? []
        var messageText = NSAttributedString.format(message: textMessageData, isObfuscated: message.isObfuscated)
        
        // Search queries
        if !searchQueries.isEmpty {
            let highlightStyle: [NSAttributedString.Key: AnyObject] = [.backgroundColor: UIColor.accentDarken]
            messageText = messageText.highlightingAppearances(of: searchQueries, with: highlightStyle, upToWidth: 0, totalMatches: nil)
        }
        
        // Quote
//        if textMessageData.hasQuote {
//            let quotedMessage = message.textMessageData?.quote
//            let quoteCell = ConversationReplyCellDescription(quotedMessage: quotedMessage)
//            cells.append(AnyConversationMessageCellDescription(quoteCell))
//        }
        
        // Text
        if !messageText.string.isEmpty {
            let senderIsSelf = message.sender?.remoteIdentifier.uuidString == ZMUser.selfUser()?.remoteIdentifier.uuidString
            let textCell = ConversationTextMessageCellDescription(attributedString: messageText, message: message, senderIsSelf: senderIsSelf, isObfuscated: message.isObfuscated)
            cells.append(AnyConversationMessageCellDescription(textCell))
        }

        guard !message.isObfuscated else {
            return cells
        }

        // Links
        if let attachment = attachments.first {
            // Link Attachment
            let attachmentCell = ConversationLinkAttachmentCellDescription(attachment: attachment, thumbnailResource: message.linkAttachmentImage)
            cells.append(AnyConversationMessageCellDescription(attachmentCell))
        } else if textMessageData.linkPreview != nil {
            // Link Preview
//            let linkPreviewCell = ConversationLinkPreviewArticleCellDescription(message: message, data: textMessageData)
//            cells.append(AnyConversationMessageCellDescription(linkPreviewCell))
        }
        
        return cells
    }
    
}
