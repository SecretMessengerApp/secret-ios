
import Foundation
import UIKit
import WireDataModel

extension Notification.Name {
    static let conversationListItemDidScroll = Notification.Name("ConversationListItemDidScroll")
}

private let listItemMinHeight: CGFloat = 64

final class ConversationListItemView: UIView {
    
    // Please use `updateForConversation:` to set conversation.
    private var conversation: ZMConversation?
    
    private var titleText: NSAttributedString? {
        didSet {
            titleField.attributedText = titleText
            titleField.textColor = .dynamic(scheme: .title)
        }
    }

    private var subtitleAttributedText: NSAttributedString? {
        didSet {
            subtitleField.attributedText = subtitleAttributedText
            subtitleField.textColor = .dynamic(scheme: .subtitle)
            subtitleField.accessibilityValue = subtitleAttributedText?.string
        }
    }
    
    private var dateAttributedText: NSAttributedString? {
        didSet {
            dateField.attributedText = dateAttributedText
            dateField.textColor = .dynamic(scheme: .subtitle)
            dateField.accessibilityValue = dateAttributedText?.string
        }
    }
    
    private var rightImageIsHidden: Bool? {
        didSet {
            rightImage.isHidden = rightImageIsHidden ?? true
        }
    }

    var selected = false {
        didSet {
            backgroundColor = selected ? .dynamic(scheme: .cellSelectedBackground) : .clear
        }
    }

    var visualDrawerOffset: CGFloat = 0 {
        didSet {
            guard oldValue != visualDrawerOffset else { return }

            NotificationCenter.default.post(name: .conversationListItemDidScroll, object: self)
        }
    }
    
    private let avatarView      = ConversationAvatarView()
    private let titleField      = UILabel()
    private let subtitleField   = UILabel()
    private let dateField       = UILabel()
    private let rightMiddleField = UILabel()
    private let rightImage         = UIImageView()
    lazy var rightAccessory     = ConversationListAccessoryView()
    private let lineView        = UIView()
    private let labelsStack     = UIStackView()
    private let iconStack       = UIStackView()
    private let iconDateStack   = UIStackView()
    private let contentStack    = UIStackView()
    

    init() {
        super.init(frame: .zero)
        setupConversationListItemView()
        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeCategoryDidChange(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)

        addMediaPlaybackManagerPlayerStateObserver()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConversationListItemView() {
        setupTitleField()
        setupSubtitleField()
        setupDateField()
        setupRightMiddleField()
        setupLabelsStack()
        setupIconStack()
        setupIconDateStack()
        setupContentStack()

        configureFont()

        rightAccessory.accessibilityIdentifier = "status"

        [titleField, subtitleField].forEach(labelsStack.addArrangedSubview)
        [rightImage, rightAccessory].forEach(iconStack.addArrangedSubview)
        [iconStack, dateField].forEach(iconDateStack.addArrangedSubview)
        [avatarView, labelsStack, iconDateStack].forEach(contentStack.addArrangedSubview)

        lineView.backgroundColor = .dynamic(scheme: .separator)
        [contentStack, lineView].forEach(addSubview)

        rightAccessory.setContentCompressionResistancePriority(.required, for: .horizontal)

        doNotCompressionAndHuggingInVerticalAndHorizontal(for: [avatarView, iconDateStack, rightImage, dateField])
                
        createConstraints()

        NotificationCenter.default.addObserver(self, selector: #selector(otherConversationListItemDidScroll(_:)), name: .conversationListItemDidScroll, object: nil)
    }
    
    private func doNotCompressionAndHuggingInVerticalAndHorizontal(for views: [UIView]) {
        views.forEach { view in
            view.setContentCompressionResistancePriority(.required, for: .vertical)
            view.setContentCompressionResistancePriority(.required, for: .horizontal)
            view.setContentHuggingPriority(.required, for: .vertical)
            view.setContentHuggingPriority(.required, for: .horizontal)
        }
    }
    
    private func createConstraints() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // height
            heightAnchor.constraint(greaterThanOrEqualToConstant: listItemMinHeight),
            
            // avatar
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CGFloat.ConversationList.horizontalMargin),
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CGFloat.ConversationList.horizontalMargin),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            // lineView
            lineView.heightAnchor.constraint(equalToConstant: .hairline),
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            
        ])
    }
    
    private func setupTitleField() {
        titleField.textColor = .dynamic(scheme: .title)
        titleField.accessibilityIdentifier = "title"
    }

    private func setupSubtitleField() {
        subtitleField.textColor = .dynamic(scheme: .subtitle)
        subtitleField.accessibilityIdentifier = "subtitle"
    }
    
    private func setupDateField() {
        dateField.textColor = .dynamic(scheme: .subtitle)
        dateField.accessibilityIdentifier = "conversation last time"
        dateField.textAlignment = .right
    }
    
    private func setupRightMiddleField() {
        rightMiddleField.translatesAutoresizingMaskIntoConstraints = false
        rightMiddleField.textColor = .dynamic(scheme: .subtitle)
        rightMiddleField.accessibilityIdentifier = "conversation right text"
        rightMiddleField.textAlignment = .right
        rightMiddleField.isHidden = true
        addSubview(rightMiddleField)
        NSLayoutConstraint.activate([
            rightMiddleField.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            rightMiddleField.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    func setupRightImage(_ image: UIImage?, _ hidden: Bool = true) {
        rightImage.image = image
        rightImage.isHidden = hidden
    }
    
    private func setupLabelsStack() {
        labelsStack.axis = .vertical
        labelsStack.alignment = .leading
        labelsStack.distribution = .fill
        labelsStack.isAccessibilityElement = true
        labelsStack.accessibilityIdentifier = "title stack"
    }
    
    private func setupIconStack() {
        iconStack.spacing = 8
        iconStack.axis = .horizontal
        iconStack.alignment = .center
        iconStack.distribution = .fill
    }
    
    private func setupIconDateStack() {
        iconDateStack.spacing = 4
        iconDateStack.axis = .vertical
        iconDateStack.alignment = .trailing
        iconDateStack.distribution = .fill
    }

    private func setupContentStack() {
        contentStack.spacing = 16
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.distribution = .fill
        labelsStack.accessibilityIdentifier = "content stack"
    }    

    private func configureFont() {
        titleField.font = FontSpec(.normal, .medium).font
    }

    // MARK: - Observer
    @objc
    private func contentSizeCategoryDidChange(_ notification: Notification?) {
        configureFont()
    }

    @objc
    private func otherConversationListItemDidScroll(_ notification: Notification?) {
        guard notification?.object as? ConversationListItemView != self,
              let otherItem = notification?.object as? ConversationListItemView else {
            return
        }

            var fraction: CGFloat
            if bounds.size.width != 0 {
                fraction = 1 - otherItem.visualDrawerOffset / bounds.size.width
            } else {
                fraction = 1
            }

            if fraction > 1.0 {
                fraction = 1.0
            } else if fraction < 0.0 {
                fraction = 0.0
            }
            alpha = 0.35 + fraction * 0.65
    }

    private func addMediaPlaybackManagerPlayerStateObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mediaPlayerStateChanged(_:)),
                                               name: .mediaPlaybackManagerPlayerStateChanged,
                                               object: nil)
    }

    @objc
    private func mediaPlayerStateChanged(_ notification: Notification?) {
        DispatchQueue.main.async(execute: {
            if self.conversation != nil &&
                AppDelegate.shared.mediaPlaybackManager?.activeMediaPlayer?.sourceMessage?.conversation == self.conversation {
                self.update(for: self.conversation)
            }
        })
    }


    func configure(with title: NSAttributedString?, subtitle: NSAttributedString?) {
        self.titleText = title
        self.subtitleAttributedText = subtitle
    }
    
    func configAvatarImage(image: UIImage) {
        self.avatarView.configure(context: .image(image: image))
    }
    
    /// configure without a conversation, i.e. when displaying a pending user
    ///
    /// - Parameters:
    ///   - title: title of the cell
    ///   - subtitle: subtitle of the cell
    ///   - users: the pending user(s) waiting for self user to accept connection request
    func configure(with title: NSAttributedString?, subtitle: NSAttributedString?, users: [UserType]) {
        self.titleText = title
        self.subtitleAttributedText = subtitle
        self.rightAccessory.icon = .pendingConnection
        avatarView.configure(context: .connect(users: users.compactMap { $0 as? ZMUser }))
        
        labelsStack.accessibilityLabel = title?.string
    }
    
    func update(for conversation: ZMConversation?) {
        self.conversation = conversation
        
        guard let conversation = conversation else {
            self.configure(with: nil, subtitle: nil)
            return
        }
        
        let status = conversation.status
        
        // Configure the subtitle
        var statusComponents: [String] = []
        let subtitle = status.description(for: conversation)
        let subtitleString = subtitle.string
        
        if !subtitleString.isEmpty {
            statusComponents.append(subtitleString)
        }
        
        // Configure the title and status
        let title: NSAttributedString?
        
        title = conversation.displayName.attributedString
        labelsStack.accessibilityLabel = conversation.displayName
        
        // Configure the avatar
        avatarView.configure(context: .conversation(conversation: conversation))
        
        rightImageIsHidden = !conversation.isPlacedTop || status.isTyping
        
        // Configure the accessory
        let statusIcon: ConversationStatusIcon?
        if let player = AppDelegate.shared.mediaPlaybackManager?.activeMediaPlayer,
            let message = player.sourceMessage,
            message.conversation == conversation {
            statusIcon = .playingMedia(isPause: player.state == .paused)
        } else {
            statusIcon = status.icon(for: conversation)
        }
        self.rightAccessory.icon = statusIcon
        self.rightAccessory.conversation = conversation
        if let statusIconAccessibilityValue = rightAccessory.accessibilityValue {
            statusComponents.append(statusIconAccessibilityValue)
        }
        
        
        dateAttributedText = status.dateDescription(for: conversation)

//        if conversation.localParticipants.first?.isPendingApproval == true {
//            statusComponents.append("pending approval")
//        }
        
        labelsStack.accessibilityValue = FormattedText.list(from: statusComponents)
        configure(with: title, subtitle: status.description(for: conversation))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    func setRightText(text: String) {
        rightMiddleField.isHidden = false
        rightMiddleField.text = text
    }
    
}
