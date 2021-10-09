
import Foundation
import Cartography

class ConversationTextNewsMessageCell: UIView, ConversationMessageCell, TextViewInteractionDelegate {
    
    struct Configuration: Equatable {
        static func == (lhs: ConversationTextNewsMessageCell.Configuration, rhs: ConversationTextNewsMessageCell.Configuration) -> Bool {
            return lhs.attributedText == rhs.attributedText
                && lhs.isObfuscated == rhs.isObfuscated
                && lhs.hasLink == rhs.hasLink
        }
        
        let attributedText: NSAttributedString
        let isObfuscated: Bool
        let hasLink: Bool
        let message: ZMConversationMessage
        let senderIsSelf: Bool
    }
    
    var configuration: Configuration?
    
    let messageTextView = LinkInteractionTextView()
    var isSelected: Bool = false
    let messageBackView = UIImageView()
    private let articleView = ArticleView(withImagePlaceholder: true)
    
    
    weak var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var menuPresenter: ConversationMessageCellMenuPresenter?
    
    private var textViewBottomConstraint: NSLayoutConstraint?
    private var textViewBottomHasLinkConstraint: NSLayoutConstraint?

    
    var ephemeralTimerTopInset: CGFloat {
        guard let font = messageTextView.font else {
            return 0
        }
        
        return font.lineHeight / 2
    }
    
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
        messageBackView.image = UIImage.init(named: MessageBackImage.other.rawValue)
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
        
        if #available(iOS 11.0, *) {
            messageTextView.textDragInteraction?.isEnabled = false
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ConversationTextNewsMessageCell.singleTap))
        tap.numberOfTapsRequired = 1
        tap.delaysTouchesBegan = true
        messageBackView.addSubview(messageTextView)
        
        articleView.delegate = self
        messageBackView.addSubview(articleView)
    }
    
    private func configureConstraints() {
        constrain(self, messageBackView) { (containView, messageBackView) in
            messageBackView.top == containView.top
            messageBackView.left == containView.left
            messageBackView.right == containView.right
            messageBackView.bottom == containView.bottom
        }
        
        
        
        constrain(messageBackView, messageTextView, articleView) { (backView, textView, articleView) in
            textView.top == backView.top + 6
            textView.left == backView.left + 16
            textView.right == backView.right - 16
            textViewBottomConstraint = textView.bottom == backView.bottom - 9

            articleView.top == textView.bottom + 10
            articleView.left == textView.left
            articleView.right == textView.right
            textViewBottomHasLinkConstraint = articleView.bottom == backView.bottom - 9
            textViewBottomHasLinkConstraint?.isActive = false
        }
        
    }
    
    func configure(with object: Configuration, animated: Bool) {
        self.configuration = object
        messageTextView.attributedText = object.attributedText
        if object.isObfuscated {
            messageTextView.accessibilityIdentifier = "Obfuscated message"
        } else {
            messageTextView.accessibilityIdentifier = "Message"
        }
        let message = object.message

        guard let textMessageData = message.textMessageData else {
            return
        }
        if textMessageData.linkPreview != nil {
            articleView.isHidden = false
            textViewBottomConstraint?.isActive = false
            textViewBottomHasLinkConstraint?.isActive = true
            articleView.configure(withTextMessageData: textMessageData, obfuscated: message.isObfuscated)
            updateImageLayout(isRegular: self.traitCollection.horizontalSizeClass == .regular)
        } else {
            articleView.isHidden = true
            textViewBottomConstraint?.isActive = true
            textViewBottomHasLinkConstraint?.isActive = false
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

        if UIApplication.shared.canOpenURL(url) {
            delegate?.conversationCellWantsToOpen?(url: url)
            return true
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

class ConversationTextNewsMessageCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationTextNewsMessageCell
    let configuration: View.Configuration

    weak var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 8

    let isFullWidth: Bool  = false
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = true

    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil
    
    init(attributedString: NSAttributedString, message: ZMConversationMessage, senderIsSelf: Bool, isObfuscated: Bool) {
        configuration = View.Configuration(attributedText: attributedString, isObfuscated: isObfuscated, hasLink: message.textMessageData?.linkPreview != nil,  message: message, senderIsSelf: senderIsSelf)
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
        guard let otherDescription = other as? ConversationTextNewsMessageCellDescription else { return false }

        return configuration == otherDescription.configuration
    }
}

extension ConversationTextNewsMessageCell: ArticleViewDelegate {
    
    func articleViewWantsToOpenURL(_ articleView: ArticleView, url: URL) {
        delegate?.conversationCellWantsToOpen?(url: url)
    }
    
}

// MARK: - Factory

extension ConversationTextNewsMessageCellDescription {
    
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
        
        // Text
        if !messageText.string.isEmpty {
            let senderIsSelf = message.sender?.remoteIdentifier.uuidString == ZMUser.selfUser()?.remoteIdentifier.uuidString
            let textCell = ConversationTextNewsMessageCellDescription(attributedString: messageText, message: message, senderIsSelf: senderIsSelf, isObfuscated: message.isObfuscated)
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
