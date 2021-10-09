
import UIKit
import Down

class ConversationReplyContentView: UIView {
    let numberOfLinesLimit: Int = 4

    struct Configuration {
        enum Content {
            case text(NSAttributedString)
            case imagePreview(thumbnail: PreviewableImageResource, isVideo: Bool)
        }

        let showDetails: Bool
        let isEdited: Bool
        let senderName: String?
        let timestamp: String?

        let content: Content
        let contentType: String
    }

    let senderComponent = SenderNameCellComponent()
    let contentTextView = UITextView()
    let timestampLabel = UILabel()
    let assetThumbnail = ImageResourceThumbnailView()

    let stackView = UIStackView()

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
        shouldGroupAccessibilityChildren = false

        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 6
        addSubview(stackView)

        senderComponent.label.accessibilityIdentifier = "original.sender"
        senderComponent.indicatorView.accessibilityIdentifier = "original.edit_icon"
        senderComponent.label.font = .mediumSemiboldFont
        senderComponent.label.textColor = .dynamic(scheme: .title)
        stackView.addArrangedSubview(senderComponent)

        contentTextView.textContainer.lineBreakMode = .byTruncatingTail
        contentTextView.textContainer.maximumNumberOfLines = numberOfLinesLimit
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.isScrollEnabled = false
        contentTextView.isUserInteractionEnabled = false
        contentTextView.textContainerInset = .zero
        contentTextView.isEditable = false
        contentTextView.isSelectable = false
        contentTextView.backgroundColor = .clear
        contentTextView.textColor = .dynamic(scheme: .title)

        contentTextView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        stackView.addArrangedSubview(contentTextView)

        assetThumbnail.shape = .rounded(radius: 4)
        assetThumbnail.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.addArrangedSubview(assetThumbnail)

        timestampLabel.accessibilityIdentifier = "original.timestamp"
        timestampLabel.font = .mediumFont
        timestampLabel.textColor = .from(scheme: .textDimmed)
        timestampLabel.numberOfLines = 1
        timestampLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.addArrangedSubview(timestampLabel)
    }

    private func configureConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            assetThumbnail.heightAnchor.constraint(lessThanOrEqualToConstant: 140),
            contentTextView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
    }


    func configure(with object: Configuration) {
        senderComponent.isHidden = !object.showDetails
        timestampLabel.isHidden = !object.showDetails

        senderComponent.senderName = object.senderName
        senderComponent.indicatorIcon = object.isEdited ? StyleKitIcon.pencil.makeImage(size: 8, color: .from(scheme: .iconNormal)) : nil
        senderComponent.indicatorLabel = object.isEdited ? "content.message.reply.edited_message".localized : nil
        timestampLabel.text = object.timestamp

        switch object.content {
        case .text(let attributedContent):
            let mutableAttributedContent = NSMutableAttributedString(attributedString: attributedContent)
            /// trim the string to first four lines to prevent last line narrower spacing issue
            mutableAttributedContent.paragraphTailTruncated()
            contentTextView.attributedText = mutableAttributedContent.trimmedToNumberOfLines(numberOfLinesLimit: numberOfLinesLimit)
            contentTextView.isHidden = false
            contentTextView.accessibilityIdentifier = object.contentType
            contentTextView.isAccessibilityElement = true
            assetThumbnail.isHidden = true
            assetThumbnail.isAccessibilityElement = false
        case .imagePreview(let resource, let isVideo):
            assetThumbnail.setResource(resource, isVideoPreview: isVideo)
            assetThumbnail.isHidden = false
            assetThumbnail.accessibilityIdentifier = object.contentType
            assetThumbnail.isAccessibilityElement = true
            contentTextView.isHidden = true
            contentTextView.isAccessibilityElement = false
        }
    }

}

class ConversationReplyCell: UIView, ConversationMessageCell {
    typealias Configuration = ConversationReplyContentView.Configuration
    var isSelected: Bool = false

    let contentView: ConversationReplyContentView
    var container: ReplyRoundCornersView

    weak var delegate: ConversationMessageCellDelegate?
    weak var message: ZMConversationMessage?

    override init(frame: CGRect) {
        contentView = ConversationReplyContentView()
        container = ReplyRoundCornersView(containedView: contentView)
        super.init(frame: frame)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureSubviews() {
        container.addTarget(self, action: #selector(onTap), for: .touchUpInside)
        addSubview(container)
    }

    private func configureConstraints() {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.fitInSuperview()
    }

    func configure(with object: Configuration, animated: Bool) {
        contentView.configure(with: object)
    }

    @objc func onTap() {
        delegate?.perform(action: .openQuote, for: message, view: self)
    }

}

class ConversationReplyCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationReplyCell
    let configuration: View.Configuration

    var showEphemeralTimer: Bool = false
    var topMargin: Float = 8
    let isFullWidth = false
    let supportsActions = false
    let containsHighlightableContent: Bool = true

    weak var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?

    let accessibilityLabel: String? = "content.message.original_label".localized
    let accessibilityIdentifier: String? = "ReplyCell"

    init(quotedMessage: ZMConversationMessage?) {
        let isEdited = quotedMessage?.updatedAt != nil
        let senderName = quotedMessage?.senderName
        let timestamp = quotedMessage?.formattedOriginalReceivedDate()

        var isUnavailable = false
        let content: View.Configuration.Content
        let contentType: String
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.smallSemiboldFont,
                                                         .foregroundColor: UIColor.dynamic(scheme: .title)]

        switch quotedMessage {
        case let message? where message.isText:
            let data = message.textMessageData!
            content = .text(NSAttributedString.formatForPreview(message: data, inputMode: false))
            contentType = "quote.type.text"

        case let message? where message.isLocation:
            let location = message.locationMessageData!
            let imageIcon = NSTextAttachment.textAttachment(for: .locationPin, with: .dynamic(scheme: .title))
            let initialString = NSAttributedString(attachment: imageIcon) + "  " + (location.name ?? "conversation.input_bar.message_preview.location".localized).localizedUppercase
            content = .text(initialString && attributes)
            contentType = "quote.type.location"

        case let message? where message.isAudio:
            let imageIcon = NSTextAttachment.textAttachment(for: .microphone, with: .dynamic(scheme: .title))
            let initialString = NSAttributedString(attachment: imageIcon) + "  " + "conversation.input_bar.message_preview.audio".localized.localizedUppercase
            content = .text(initialString && attributes)
            contentType = "quote.type.audio"

        case let message? where message.isImage:
            content = .imagePreview(thumbnail: message.imageMessageData!.image, isVideo: false)
            contentType = "quote.type.image"

        case let message? where message.isVideo:
            content = .imagePreview(thumbnail: message.fileMessageData!.thumbnailImage, isVideo: true)
            contentType = "quote.type.video"

        case let message? where message.isFile:
            let fileData = message.fileMessageData!
            let imageIcon = NSTextAttachment.textAttachment(for: .document, with: .dynamic(scheme: .title))
            let initialString = NSAttributedString(attachment: imageIcon) + "  " + (fileData.filename ?? "conversation.input_bar.message_preview.file".localized).localizedUppercase
            content = .text(initialString && attributes)
            contentType = "quote.type.file"

        default:
            isUnavailable = true
            let attributes: [NSAttributedString.Key: AnyObject] = [.font: UIFont.mediumFont.italic, .foregroundColor: UIColor.from(scheme: .textDimmed)]
            content = .text(NSAttributedString(string: "content.message.reply.broken_message".localized, attributes: attributes))
            contentType = "quote.type.unavailable"
        }

        configuration = View.Configuration(showDetails: !isUnavailable, isEdited: isEdited, senderName: senderName, timestamp: timestamp, content: content, contentType: contentType)
    }

}

