
import Foundation

extension ZMConversationMessage {
    func replyPreview() -> UIView? {
        guard self.canBeQuoted else {
            return nil
        }
        return preparePreviewView()
    }
    
    func preparePreviewView(shouldDisplaySender: Bool = true) -> UIView {
        if self.isImage || self.isVideo {
            return MessageThumbnailPreviewView(message: self, displaySender: shouldDisplaySender)
        }
        else {
            return MessagePreviewView(message: self, displaySender: shouldDisplaySender)
        }
    }
}

extension UITextView {
    fileprivate static func previewTextView() -> UITextView {
        let textView = UITextView()
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.textContainer.maximumNumberOfLines = 1
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        
        textView.isEditable = false
        textView.isSelectable = true
        
        textView.backgroundColor = .clear
        textView.textColor = .dynamic(scheme: .title)
        
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        return textView
    }
}

final class MessageThumbnailPreviewView: UIView, Themeable {
    private let senderLabel = UILabel()
    private let contentTextView = UITextView.previewTextView()
    private let imagePreview = ImageResourceView()
    private var observerToken: Any? = nil
    private let displaySender: Bool

    let message: ZMConversationMessage
    
    @objc dynamic var colorSchemeVariant: ColorSchemeVariant = ColorScheme.default.variant {
        didSet {
            guard oldValue != colorSchemeVariant else { return }
            applyColorScheme(colorSchemeVariant)
        }
    }
    
    init(message: ZMConversationMessage, displaySender: Bool = true) {
        require(message.canBeQuoted || !displaySender)
        require(message.conversation != nil)
        self.message = message
        self.displaySender = displaySender
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupMessageObserver()
        updateForMessage()
    }
    
    private func setupMessageObserver() {
        if let userSession = ZMUserSession.shared() {
            observerToken = MessageChangeInfo.add(observer: self,
                                                  for: message,
                                                  userSession: userSession)
        }
    }
    
    private static let thumbnailSize: CGFloat = 42
    
    private func setupSubviews() {
        var allViews: [UIView] = [contentTextView, imagePreview]
        
        if displaySender {
            allViews.append(senderLabel)
            senderLabel.font = .mediumSemiboldFont
            senderLabel.textColor = .dynamic(scheme: .title)
            senderLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        
        imagePreview.clipsToBounds = true
        imagePreview.contentMode = .scaleAspectFill
        imagePreview.imageSizeLimit = .maxDimensionForShortSide(MessageThumbnailPreviewView.thumbnailSize * UIScreen.main.scale)
        imagePreview.layer.cornerRadius = 4
        
        allViews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        allViews.forEach(self.addSubview)
    }
    
    private func setupConstraints() {
        
        let inset: CGFloat = 12
        
        NSLayoutConstraint.activate([
            contentTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            contentTextView.trailingAnchor.constraint(equalTo: imagePreview.leadingAnchor, constant: inset),
            imagePreview.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            imagePreview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            imagePreview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            imagePreview.widthAnchor.constraint(equalToConstant: MessageThumbnailPreviewView.thumbnailSize),
            imagePreview.heightAnchor.constraint(equalToConstant: MessageThumbnailPreviewView.thumbnailSize),
            ])
        
        if displaySender {
            NSLayoutConstraint.activate([
                
                senderLabel.topAnchor.constraint(equalTo: topAnchor, constant: inset),
                senderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
                senderLabel.trailingAnchor.constraint(equalTo: imagePreview.leadingAnchor, constant: inset),
                contentTextView.topAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: inset),
                contentTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
                ])
        } else {
            contentTextView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }

    private func editIcon() -> NSAttributedString {
        if message.updatedAt != nil {
            return "  " + NSAttributedString(attachment: NSTextAttachment.textAttachment(for: .pencil, with: .dynamic(scheme: .title), iconSize: 8))
        }
        else {
            return NSAttributedString()
        }
    }
    
    private func updateForMessage() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.smallSemiboldFont,
            .foregroundColor: UIColor.dynamic(scheme: .title)
        ]

        senderLabel.attributedText = (message.senderName && attributes) + self.editIcon()

        if message.isImage {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.smallSemiboldFont,
                .foregroundColor: UIColor.dynamic(scheme: .title)
            ]
            let imageIcon = NSTextAttachment.textAttachment(for: .photo, with: .dynamic(scheme: .title), verticalCorrection: -1)
            let initialString = NSAttributedString(attachment: imageIcon) + "  " + "conversation.input_bar.message_preview.image".localized.localizedUppercase
            contentTextView.attributedText = initialString && attributes
            
            if let imageResource = message.imageMessageData?.image {
                imagePreview.setImageResource(imageResource)
            }
        }
        else if message.isVideo, let fileMessageData = message.fileMessageData {
            let imageIcon = NSTextAttachment.textAttachment(for: .videoCall, with: .dynamic(scheme: .title), verticalCorrection: -1)
            let initialString = NSAttributedString(attachment: imageIcon) + "  " + "conversation.input_bar.message_preview.video".localized.localizedUppercase
            contentTextView.attributedText = initialString && attributes
            
            imagePreview.setImageResource(fileMessageData.thumbnailImage)
        }
        else {
            fatal("Unknown message for preview: \(message)")
        }
    }
    
    func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        updateForMessage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessageThumbnailPreviewView: ZMMessageObserver {
    func messageDidChange(_ changeInfo: MessageChangeInfo) {
        guard !message.hasBeenDeleted else {
            return // Deleted message won't have any content
        }
        
        updateForMessage()
    }
}

final class MessagePreviewView: UIView, Themeable {
    
    private let senderLabel = UILabel()
    private let contentTextView = UITextView.previewTextView()
    private var observerToken: Any? = nil
    private let displaySender: Bool

    let message: ZMConversationMessage
    
    @objc dynamic var colorSchemeVariant: ColorSchemeVariant = ColorScheme.default.variant {
        didSet {
            guard oldValue != colorSchemeVariant else { return }
            applyColorScheme(colorSchemeVariant)
        }
    }
    
    init(message: ZMConversationMessage, displaySender: Bool = true) {
        require(message.canBeQuoted || !displaySender)
        require(message.conversation != nil)
        self.message = message
        self.displaySender = displaySender
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupMessageObserver()
        updateForMessage()
    }
    
    private func setupMessageObserver() {
        if let userSession = ZMUserSession.shared() {
            observerToken = MessageChangeInfo.add(observer: self,
                                                  for: message,
                                                  userSession: userSession)
        }
    }
    
    private func setupSubviews() {
        var allViews: [UIView] = [contentTextView]
        
        if displaySender {
            allViews.append(senderLabel)
            senderLabel.font = .mediumSemiboldFont
            senderLabel.textColor = .dynamic(scheme: .title)
            senderLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        allViews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        allViews.forEach(self.addSubview)
    }
    
    private func setupConstraints() {
        let inset: CGFloat = 12

        NSLayoutConstraint.activate([
            contentTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            contentTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            contentTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
        ])
        
        if displaySender {
            NSLayoutConstraint.activate([
                senderLabel.topAnchor.constraint(equalTo: topAnchor, constant: inset),
                senderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
                senderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
                contentTextView.topAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: inset / 2),
                ])
        } else {
            contentTextView.topAnchor.constraint(equalTo: topAnchor, constant: inset).isActive = true
        }
    }
    
    private func editIcon() -> NSAttributedString {
        if message.updatedAt != nil {
            return "  " + NSAttributedString(attachment: NSTextAttachment.textAttachment(for: .pencil, with: .dynamic(scheme: .title), iconSize: 8))
        }
        else {
            return NSAttributedString()
        }
    }

    private func updateForMessage() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.smallSemiboldFont,
            .foregroundColor: UIColor.dynamic(scheme: .title)
        ]
        
        senderLabel.attributedText = (message.senderName && attributes) + self.editIcon()
        
        if let textMessageData = message.textMessageData {
            contentTextView.attributedText = NSAttributedString.formatForPreview(message: textMessageData, inputMode: true, variant: colorSchemeVariant)
        }
        else if let location = message.locationMessageData {
            let imageIcon = NSTextAttachment.textAttachment(for: .locationPin, with: .dynamic(scheme: .title), verticalCorrection: -1)
            let initialString = NSAttributedString(attachment: imageIcon) + "  " + (location.name ?? "conversation.input_bar.message_preview.location".localized).localizedUppercase
            contentTextView.attributedText = initialString && attributes
        }
        else if message.isAudio {
            let imageIcon = NSTextAttachment.textAttachment(for: .microphone, with: .dynamic(scheme: .title), verticalCorrection: -1)
            let initialString = NSAttributedString(attachment: imageIcon) + "  " + "conversation.input_bar.message_preview.audio".localized.localizedUppercase
            contentTextView.attributedText = initialString && attributes
        }
        else if let fileData = message.fileMessageData {
            let imageIcon = NSTextAttachment.textAttachment(for: .document, with: .dynamic(scheme: .title), verticalCorrection: -1)
            let initialString = NSAttributedString(attachment: imageIcon) + "  " + (fileData.filename ?? "conversation.input_bar.message_preview.file".localized).localizedUppercase
            contentTextView.attributedText = initialString && attributes
        }
    }
    
    func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        updateForMessage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessagePreviewView: ZMMessageObserver {
    func messageDidChange(_ changeInfo: MessageChangeInfo) {
        updateForMessage()
    }
}
