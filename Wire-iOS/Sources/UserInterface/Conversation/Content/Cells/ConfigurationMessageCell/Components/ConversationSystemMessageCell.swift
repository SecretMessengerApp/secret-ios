
import UIKit

// MARK: - Cells

class ConversationSystemMessageCell: ConversationIconBasedCell, ConversationMessageCell {

    struct Configuration: Equatable {
        let icon: UIImage?
        let attributedText: NSAttributedString?
        let showLine: Bool
        
        static func == (lhs: ConversationSystemMessageCell.Configuration, rhs: ConversationSystemMessageCell.Configuration) -> Bool {
            return
                lhs.attributedText == rhs.attributedText
                && lhs.showLine == rhs.showLine
        }
    }

    // MARK: - Configuration

    func configure(with object: Configuration, animated: Bool) {
        lineView.isHidden = !object.showLine
        imageView.image = object.icon
        attributedText = object.attributedText
    }

}

class ConversationStartedSystemMessageCell: ConversationIconBasedCell, ConversationMessageCell {
    
    struct Configuration {
        let title: NSAttributedString?
        let message: NSAttributedString
        let selectedUsers: [ZMUser]
        let icon: UIImage?
    }
    
    private let titleLabel = UILabel()
    private var selectedUsers: [ZMUser] = []
    
    override func configureSubviews() {
        super.configureSubviews()
        
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        topContentView.addSubview(titleLabel)
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        titleLabel.fitInSuperview()
    }
    
    func configure(with object: Configuration, animated: Bool) {
        titleLabel.attributedText = object.title
        attributedText = object.message
        imageView.image = object.icon
        selectedUsers = object.selectedUsers
    }

}

// MARK: - UITextViewDelegate
extension ConversationStartedSystemMessageCell {

    public override func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

        delegate?.conversationMessageWantsToOpenParticipantsDetails(self, selectedUsers: selectedUsers, sourceView: self)

        return false
    }

}

class ParticipantsConversationSystemMessageCell: ConversationIconBasedCell, ConversationMessageCell {
    
    struct Configuration: Equatable {
        let icon: UIImage?
        let attributedText: NSAttributedString?
        let showLine: Bool
        let warning: String?
        static func == (lhs: ParticipantsConversationSystemMessageCell.Configuration, rhs: ParticipantsConversationSystemMessageCell.Configuration) -> Bool {
            return
                lhs.attributedText == rhs.attributedText
                && lhs.showLine == rhs.showLine
                && lhs.warning == rhs.warning
        }
    }
    
    private let warningLabel = UILabel()
    
    override func configureSubviews() {
        super.configureSubviews()
        warningLabel.numberOfLines = 0
        warningLabel.isAccessibilityElement = true
        warningLabel.font = FontSpec(.small, .regular).font
        warningLabel.textColor = .vividRed
        bottomContentView.addSubview(warningLabel)
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        warningLabel.fitInSuperview()
    }
    
    // MARK: - Configuration
    
    func configure(with object: Configuration, animated: Bool) {
        lineView.isHidden = !object.showLine
        imageView.image = object.icon
        attributedText = object.attributedText
        warningLabel.text = object.warning
    }
}

class LinkConversationSystemMessageCell: ConversationIconBasedCell, ConversationMessageCell {

    struct Configuration: Equatable {
        static func == (lhs: LinkConversationSystemMessageCell.Configuration, rhs: LinkConversationSystemMessageCell.Configuration) -> Bool {
            return
                lhs.attributedText == rhs.attributedText
                && lhs.showLine == rhs.showLine
                && lhs.url == rhs.url
        }
        let icon: UIImage?
        let attributedText: NSAttributedString?
        let showLine: Bool
        let url: URL
        let message: ZMConversationMessage
    }

    var lastConfiguration: Configuration?

    // MARK: - Configuration

    func configure(with object: Configuration, animated: Bool) {
        lastConfiguration = object
        lineView.isHidden = !object.showLine
        imageView.image = object.icon
        attributedText = object.attributedText
    }
}

// MARK: - UITextViewDelegate

extension LinkConversationSystemMessageCell {

    public override func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if let _ = lastConfiguration?.url {
            let alertVC = UIAlertController(title: "profile.devices.detail.reset_session.title".localized, message: nil, preferredStyle: UIAlertController.Style.alert)
            alertVC.addAction(UIAlertAction(title: "hud.cancelled".localized, style: UIAlertAction.Style.default, handler: nil))
            alertVC.addAction(UIAlertAction(title: "controller.alert.ok".localized, style: UIAlertAction.Style.default, handler: { (_) in
                if let msg = self.lastConfiguration?.message as? ZMSystemMessage,
                    let client = msg.clients.first as? UserClient{
                    ZMUserSession.shared()?.performChanges {
                        client.resetSession()
                    }
                }
            }))
            UIApplication.shared.topmostViewController()?.present(alertVC, animated: true, completion: nil)
        }
        return false
    }
    
}


class NewDeviceSystemMessageCell: ConversationIconBasedCell, ConversationMessageCell {
    
    static let userClientURL: URL = URL(string: "settings://user-client")!
    
    var linkTarget: LinkTarget? = nil
    
    enum LinkTarget {
        case user(ZMUser)
        case conversation(ZMConversation)
    }
    
    struct Configuration {
        let attributedText: NSAttributedString?
        var icon: UIImage?
        var linkTarget: LinkTarget
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    func setupView() {
        lineView.isHidden = false
    }
    
    func configure(with object: Configuration, animated: Bool) {
        attributedText = object.attributedText
        imageView.image = object.icon
        linkTarget = object.linkTarget
    }
    
}

// MARK: - UITextViewDelegate

extension NewDeviceSystemMessageCell {

    public override func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

        guard let linkTarget = linkTarget,
              url == type(of: self).userClientURL,
              let zClientViewController = ZClientViewController.shared else { return false }

        switch linkTarget {
        case .user(let user):
            zClientViewController.openClientListScreen(for: user)
        case .conversation(let conversation):
            zClientViewController.openDetailScreen(for: conversation)
        }

        return false
    }

}

class ConversationRenamedSystemMessageCell: ConversationIconBasedCell, ConversationMessageCell {

    struct Configuration {
        let attributedText: NSAttributedString
        let newConversationName: NSAttributedString
    }

    var nameLabelFont: UIFont? = .normalSemiboldFont
    private let nameLabel = UILabel()

    override func configureSubviews() {
        super.configureSubviews()
        nameLabel.numberOfLines = 0
        imageView.setIcon(.pencil, size: 16, color: .dynamic(scheme: .title))
        bottomContentView.addSubview(nameLabel)
    }

    override func configureConstraints() {
        super.configureConstraints()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: bottomContentView.topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: bottomContentView.bottomAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: bottomContentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: bottomContentView.trailingAnchor)
        ])
    }

    // MARK: - Configuration

    func configure(with object: Configuration, animated: Bool) {
        lineView.isHidden = false
        attributedText = object.attributedText
        nameLabel.attributedText = object.newConversationName
        nameLabel.accessibilityLabel = nameLabel.attributedText?.string
    }

}

// MARK: - Factory

class ConversationSystemMessageCellDescription {

    static func cells(for message: ZMConversationMessage) -> [AnyConversationMessageCellDescription] {
        guard let systemMessageData = message.systemMessageData,
            let sender = message.sender,
            let conversation = message.conversation else {
            preconditionFailure("Invalid system message")
        }

        switch systemMessageData.systemMessageType {
        case .connectionRequest, .connectionUpdate:
            break // Deprecated

        case .conversationNameChanged:
            guard let newName = systemMessageData.text else {
                fallthrough
            }

            let renamedCell = ConversationRenamedSystemMessageCellDescription(message: message, data: systemMessageData, sender: sender, newName: newName)
            return [AnyConversationMessageCellDescription(renamedCell)]

        case .missedCall:
            let missedCallCell = ConversationCallSystemMessageCellDescription(message: message, data: systemMessageData, missed: true)
            return [AnyConversationMessageCellDescription(missedCallCell)]

        case .performedCall:
            let callCell = ConversationCallSystemMessageCellDescription(message: message, data: systemMessageData, missed: false)
            return [AnyConversationMessageCellDescription(callCell)]

        case .messageDeletedForEveryone:
            let senderCell = ConversationSenderMessageCellDescription(sender: sender, message: message)
            return [AnyConversationMessageCellDescription(senderCell)]

        case .messageTimerUpdate:
            guard let timer = systemMessageData.messageTimer else {
                fallthrough
            }

            let timerCell = ConversationMessageTimerCellDescription(message: message, data: systemMessageData, timer: timer, sender: sender)
            return [AnyConversationMessageCellDescription(timerCell)]

        case .conversationIsSecure:
            let shieldCell = ConversationVerifiedSystemMessageSectionDescription()
            return [AnyConversationMessageCellDescription(shieldCell)]

        case .decryptionFailed:
            let decryptionCell = ConversationCannotDecryptSystemMessageCellDescription(message: message, data: systemMessageData, sender: sender, remoteIdentityChanged: false)
            return [AnyConversationMessageCellDescription(decryptionCell)]

        case .decryptionFailed_RemoteIdentityChanged:
            let decryptionCell = ConversationCannotDecryptSystemMessageCellDescription(message: message, data: systemMessageData, sender: sender, remoteIdentityChanged: true)
            return [AnyConversationMessageCellDescription(decryptionCell)]

        case .newClient, .usingNewDevice, .reactivatedDevice:
            let newClientCell = ConversationNewDeviceSystemMessageCellDescription(message: message, systemMessageData: systemMessageData, conversation: conversation)
            return [AnyConversationMessageCellDescription(newClientCell)]

        case .ignoredClient:
            guard let user = systemMessageData.users.first else { fallthrough }
            let ignoredClientCell = ConversationIgnoredDeviceSystemMessageCellDescription(message: message, data: systemMessageData, user: user)
            return [AnyConversationMessageCellDescription(ignoredClientCell)]
            
        case .potentialGap:
            let missingMessagesCell = ConversationMissingMessagesSystemMessageCellDescription(message: message, data: systemMessageData)
            return [AnyConversationMessageCellDescription(missingMessagesCell)]
            
        case .participantsAdded:
            
            let participantsChangedCell = ConversationParticipantsChangedSystemMessageCellDescription(message: message, data: systemMessageData)
            
            if  let selfID = ZMUser.selfUser()?.remoteIdentifier.transportString(),
                let userIDs = systemMessageData.userIDs,
                userIDs.contains(selfID) {
                return [
                    AnyConversationMessageCellDescription(participantsChangedCell)
                ]
            } else {
                return [AnyConversationMessageCellDescription(participantsChangedCell)]
            }
            
        case .participantsRemoved:
            let participantsChangedCell = ConversationParticipantsChangedSystemMessageCellDescription(message: message, data: systemMessageData)
            return [AnyConversationMessageCellDescription(participantsChangedCell)]
            
        case .memberDisableSendMsg,.allDisableSendMsg:
            let disableSendCell = ConversationSystemDisableSendMsgCellDescription(message: message)
            return [AnyConversationMessageCellDescription(disableSendCell)]
        case .allowAddFriend:
            let addFriendsCell = ConversationSystemAllowAddFriendsCellDescription(message: message)
            return [AnyConversationMessageCellDescription(addFriendsCell)]
        case .messageVisible:
            let messageVisibleCell = ConversationSystemMessageVisibleCellDescription(message: message)
            return [AnyConversationMessageCellDescription(messageVisibleCell)]
        case .screenShotOpened, .screenShotClosed:
            let screenShotCell = ConversationSystemOptionScreenShotCellDescription(message: message)
            return [AnyConversationMessageCellDescription(screenShotCell)]
        case .managerMsg:
            let managerMsgCell = ConversationSystemGroupManagerMsgCellDescription(message: message)
            return [AnyConversationMessageCellDescription(managerMsgCell)]
        case .creatorChangeMsg:
            let creatorChangeCell = ConversationSystemCreatorChangeMsgCellDescription(message: message)
            return [AnyConversationMessageCellDescription(creatorChangeCell)]

        case .readReceiptsEnabled,
             .readReceiptsDisabled,
             .readReceiptsOn:
            let cell = ConversationReadReceiptSettingChangedCellDescription(sender: sender,
                                                                            systemMessageType: systemMessageData.systemMessageType)
            return [AnyConversationMessageCellDescription(cell)]
            
        case .newConversation:
            var cells: [AnyConversationMessageCellDescription] = []
            let startedConversationCell = ConversationStartedSystemMessageCellDescription(message: message, data: systemMessageData)
            cells.append(AnyConversationMessageCellDescription(startedConversationCell))
            
//            let isOpenGroup = conversation.conversationType == .group && conversation.allowGuests
//            let selfCanAddUsers = ZMUser.selfUser()?.canAddUser(to: conversation) ?? false
            
          
//            if selfCanAddUsers && isOpenGroup {
//                cells.append(AnyConversationMessageCellDescription(GuestsAllowedCellDescription()))
//            }
            
            return cells
        case .showMemsum:
            let disableSendCell = ConversationSystemDisableShowMemsumCell(message: message)
            return [AnyConversationMessageCellDescription(disableSendCell)]
        case .allowViewmen:
            let disableSendCell = ConversationSystemAllowViewmemCell(message: message)
            return [AnyConversationMessageCellDescription(disableSendCell)]
        case .enabledEditMsg:
            let disableSendCell = ConversationSystemEnableEditMsgCell(message: message)
            return [AnyConversationMessageCellDescription(disableSendCell)]
        default:
            let unknownMessage = UnknownMessageCellDescription()
            return [AnyConversationMessageCellDescription(unknownMessage)]
        }

        return []
    }

}

// MARK: - Descriptions


class ConversationParticipantsChangedSystemMessageCellDescription: ConversationMessageCellDescription {
    typealias View = ParticipantsConversationSystemMessageCell
    let configuration: View.Configuration
    
    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 0
    
    let isFullWidth: Bool = true
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = false
    
    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil
    
    init(message: ZMConversationMessage, data: ZMSystemMessageData) {
        let color = UIColor.dynamic(scheme: .title)

        let model = ParticipantsCellViewModel(font: .mediumFont, boldFont: .mediumSemiboldFont, largeFont: .largeSemiboldFont, textColor: color, iconColor: color, message: message)
        configuration = View.Configuration(icon: model.image(), attributedText: model.attributedTitle(), showLine: true, warning: model.warning())
        actionController = nil
    }

    func isConfigurationEqual(with description: Any) -> Bool {
        guard let otherSystemMessageDescription = description as? ConversationParticipantsChangedSystemMessageCellDescription else {
            return false
        }

        return self.configuration == otherSystemMessageDescription.configuration
    }
}

class ConversationRenamedSystemMessageCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationRenamedSystemMessageCell
    let configuration: View.Configuration

    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 0

    let isFullWidth: Bool = true
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = false

    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil

    init(message: ZMConversationMessage, data: ZMSystemMessageData, sender: ZMUser, newName: String) {
        let senderText = message.senderName
        let titleString = "content.system.renamed_conv.title".localized(pov: sender.pov, args: senderText)

        let title = NSAttributedString(string: titleString, attributes: [.font: UIFont.mediumFont, .foregroundColor: UIColor.dynamic(scheme: .title)])
            .adding(font: .mediumSemiboldFont, to: senderText)

        let conversationName = NSAttributedString(string: newName, attributes: [.font: UIFont.normalSemiboldFont, .foregroundColor: UIColor.dynamic(scheme: .title)])
        configuration = View.Configuration(attributedText: title, newConversationName: conversationName)
        actionController = nil
    }

}

class ConversationCallSystemMessageCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationSystemMessageCell
    let configuration: View.Configuration

    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 0

    let isFullWidth: Bool = true
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = false

    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil

    init(message: ZMConversationMessage, data: ZMSystemMessageData, missed: Bool) {
        let viewModel = CallCellViewModel(
            icon: missed ? .endCall : .phone,
            iconColor: UIColor(for: missed ? .vividRed : .strongLimeGreen),
            systemMessageType: data.systemMessageType,
            font: .mediumFont,
            boldFont: .mediumSemiboldFont,
            textColor: .dynamic(scheme: .title),
            message: message
        )

        configuration = View.Configuration(icon: viewModel.image(), attributedText: viewModel.attributedTitle(), showLine: false)
        actionController = nil
    }

    func isConfigurationEqual(with other: Any) -> Bool {
        guard let otherDescription = other as? ConversationCallSystemMessageCellDescription else {
            return false
        }

        return self.configuration == otherDescription.configuration
    }
}

class ConversationMessageTimerCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationSystemMessageCell
    let configuration: View.Configuration

    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate? 
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 0

    let isFullWidth: Bool = true
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = false

    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil

    init(message: ZMConversationMessage, data: ZMSystemMessageData, timer: NSNumber, sender: ZMUser) {
        let senderText = message.senderName
        let timeoutValue = MessageDestructionTimeoutValue(rawValue: timer.doubleValue)

        var updateText: NSAttributedString? = nil
        let baseAttributes = View.baseAttributes

        if timeoutValue == .none {
            updateText = NSAttributedString(string: "content.system.message_timer_off".localized(pov: sender.pov, args: senderText), attributes: baseAttributes)
                .adding(font: .mediumSemiboldFont, to: senderText)

        } else if let displayString = timeoutValue.localizedText {
            let timerString = displayString.replacingOccurrences(of: String.breakingSpace, with: String.nonBreakingSpace)
            updateText = NSAttributedString(string: "content.system.message_timer_changes".localized(pov: sender.pov, args: senderText, timerString), attributes: baseAttributes)
                .adding(font: .mediumSemiboldFont, to: senderText)
                .adding(font: .mediumSemiboldFont, to: timerString)
        }

        let icon = StyleKitIcon.hourglass.makeImage(size: 16, color: UIColor.from(scheme: .textDimmed))
        configuration = View.Configuration(icon: icon, attributedText: updateText, showLine: false)
        actionController = nil
    }

}

class ConversationVerifiedSystemMessageSectionDescription: ConversationMessageCellDescription {
    typealias View = ConversationSystemMessageCell
    let configuration: View.Configuration

    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 0

    let isFullWidth: Bool = true
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = false

    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil

    init() {
        let title = NSAttributedString(
            string: "content.system.is_verified".localized,
            attributes: View.baseAttributes
        )

        configuration = View.Configuration(icon: WireStyleKit.imageOfShieldverified, attributedText: title, showLine: true)
        actionController = nil
    }
}

class ConversationStartedSystemMessageCellDescription: ConversationMessageCellDescription {
    
    typealias View = ConversationStartedSystemMessageCell
    let configuration: View.Configuration
    
    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 0
    
    let isFullWidth: Bool = true
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = false
    
    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil
    
    init(message: ZMConversationMessage, data: ZMSystemMessageData) {
        let color = UIColor.dynamic(scheme: .title)
        let model = ParticipantsCellViewModel(font: .mediumFont, boldFont: .mediumSemiboldFont, largeFont: .largeSemiboldFont, textColor: color, iconColor: color, message: message)
        
        actionController = nil
        configuration =  View.Configuration(title: model.attributedHeading(),
                                            message: model.attributedTitle() ?? NSAttributedString(string: ""),
                                            selectedUsers: model.selectedUsers,
                                            icon: model.image())
    }
    
}

class ConversationMissingMessagesSystemMessageCellDescription: ConversationMessageCellDescription {
    
    typealias View = ConversationSystemMessageCell
    let configuration: View.Configuration
    
    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 0
    
    let isFullWidth: Bool = true
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = false
    
    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil
    
    init(message: ZMConversationMessage, data: ZMSystemMessageData) {
        let title = ConversationMissingMessagesSystemMessageCellDescription.makeAttributedString(systemMessageData: data)
        configuration =  View.Configuration(icon: StyleKitIcon.exclamationMark.makeImage(size: .tiny, color: .vividRed), attributedText: title, showLine: true)
        actionController = nil
    }
    
    private static func makeAttributedString(systemMessageData: ZMSystemMessageData) -> NSAttributedString {
        let font = UIFont.mediumFont
        let boldFont = UIFont.mediumSemiboldFont
        let color = UIColor.dynamic(scheme: .title)
        
        func attributedLocalizedUppercaseString(_ localizationKey: String, _ users: Set<ZMUser>) -> NSAttributedString? {
            guard users.count > 0 else { return nil }
            let userNames = users.map { $0.displayName }.joined(separator: ", ")
            let string = localizationKey.localized(args: userNames + " ", users.count) + ". "
                && font && color
            return string.addAttributes([.font: boldFont], toSubstring: userNames)
        }
        
        var title = "content.system.missing_messages.title".localized && font && color
        
        // We only want to display the subtitle if we have the final added and removed users and either one is not empty
        let addedOrRemovedUsers = !systemMessageData.addedUsers.isEmpty || !systemMessageData.removedUsers.isEmpty
        if !systemMessageData.needsUpdatingUsers && addedOrRemovedUsers {
            title += "\n\n" + "content.system.missing_messages.subtitle_start".localized + " " && font && color
            title += attributedLocalizedUppercaseString("content.system.missing_messages.subtitle_added", systemMessageData.addedUsers)
            title += attributedLocalizedUppercaseString("content.system.missing_messages.subtitle_removed", systemMessageData.removedUsers)
        }
        
        return title
    }
    
}

class ConversationIgnoredDeviceSystemMessageCellDescription: ConversationMessageCellDescription {
    
    typealias View = NewDeviceSystemMessageCell
    let configuration: View.Configuration
    
    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 0
    
    let isFullWidth: Bool = true
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = false
    
    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil
    
    init(message: ZMConversationMessage, data: ZMSystemMessageData, user: ZMUser) {
        let title = ConversationIgnoredDeviceSystemMessageCellDescription.makeAttributedString(systemMessage: data, user: user)
        
        configuration =  View.Configuration(attributedText: title, icon: WireStyleKit.imageOfShieldnotverified, linkTarget: .user(user))
        actionController = nil
    }
    
    private static func makeAttributedString(systemMessage: ZMSystemMessageData, user: ZMUser) -> NSAttributedString {
        
        let youString = "content.system.you_started".localized
        let deviceString : String
        
        if user.isSelfUser == true {
            deviceString = "content.system.your_devices".localized
        } else {
            deviceString = String(format: "content.system.other_devices".localized, user.displayName)
        }
        
        let baseString = "content.system.unverified".localized
        let endResult = String(format: baseString, youString, deviceString)
        
        let youRange = (endResult as NSString).range(of: youString)
        let deviceRange = (endResult as NSString).range(of: deviceString)
        
        let attributedString = NSMutableAttributedString(string: endResult)
        attributedString.addAttributes([.font: UIFont.mediumFont, .foregroundColor: UIColor.dynamic(scheme: .title)], range:NSRange(location: 0, length: endResult.count))
        attributedString.addAttributes([.font: UIFont.mediumSemiboldFont, .foregroundColor: UIColor.dynamic(scheme: .title)], range: youRange)
        attributedString.addAttributes([.font: UIFont.mediumFont, .link: View.userClientURL], range: deviceRange)
        
        return  NSAttributedString(attributedString: attributedString)
    }
    
}

class ConversationCannotDecryptSystemMessageCellDescription: ConversationMessageCellDescription {
    typealias View = LinkConversationSystemMessageCell
    let configuration: View.Configuration

    static fileprivate let generalErrorURL : URL = URL(string:"action://general-error")!
    static fileprivate let remoteIDErrorURL : URL = URL(string:"action://remote-id-error")!

    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 0

    let isFullWidth: Bool = true
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = false

    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil

    init(message: ZMConversationMessage, data: ZMSystemMessageData, sender: ZMUser, remoteIdentityChanged: Bool) {
        let exclamationColor = UIColor(for: .vividRed)
        let icon = StyleKitIcon.exclamationMark.makeImage(size: 16, color: exclamationColor)
        let link: URL = remoteIdentityChanged ? .wr_cannotDecryptNewRemoteIDHelp : .wr_cannotDecryptHelp

        let title = ConversationCannotDecryptSystemMessageCellDescription
            .makeAttributedString(
                systemMessage: data,
                sender: sender,
                remoteIDChanged:
                remoteIdentityChanged,
                link: link
            )

        configuration = View.Configuration(icon: icon, attributedText: title, showLine: false, url: link, message: message)
        actionController = nil
    }

    // MARK: - Localization

    private static let BaseLocalizationString = "content.system.cannot_decrypt"
    private static let IdentityString = ".identity"

    private static func makeAttributedString(systemMessage: ZMSystemMessageData, sender: ZMUser, remoteIDChanged: Bool, link: URL) -> NSAttributedString {
        let name = localizedWhoPart(sender, remoteIDChanged: remoteIDChanged)

        let why = NSAttributedString(string: localizedResetSessionPart(remoteIDChanged),
                                     attributes: [.font: UIFont.mediumFont, .link: link as AnyObject, .foregroundColor: UIColor.dynamic(scheme: .title)])

        let device : NSAttributedString
        if Bundle.developerModeEnabled {
            device = "\n" + NSAttributedString(string: localizedDevice(systemMessage.clients.first as? UserClient),
                                               attributes: [.font: UIFont.mediumFont, .foregroundColor: UIColor.from(scheme: .textDimmed)])
        } else {
            device = NSAttributedString()
        }

        let messageString = NSAttributedString(string: localizedWhatPart(remoteIDChanged, name: name),
                                               attributes: [.font: UIFont.mediumFont, .foregroundColor: UIColor.dynamic(scheme: .title)])

        let fullString = messageString + " " + why + device
        return fullString.addAttributes([.font: UIFont.mediumSemiboldFont], toSubstring:name)
    }

    private static func localizedWhoPart(_ sender: ZMUser, remoteIDChanged: Bool) -> String {
        switch (sender.isSelfUser, remoteIDChanged) {
        case (true, _):
            return (BaseLocalizationString + (remoteIDChanged ? IdentityString : "") + ".you_part").localized
        case (false, true):
            return (BaseLocalizationString + IdentityString + ".otherUser_part").localized(args: sender.displayName)
        case (false, false):
            return sender.displayName
        }
    }

    private static func localizedWhatPart(_ remoteIDChanged: Bool, name: String) -> String {
        return (BaseLocalizationString + (remoteIDChanged ? IdentityString : "")).localized(args: name)
    }

    private static func localizedWhyPart(_ remoteIDChanged: Bool) -> String {
        return (BaseLocalizationString + (remoteIDChanged ? IdentityString : "")+".why_part").localized
    }
    
    private static func localizedResetSessionPart(_ remoteIDChanged: Bool) -> String {
        return (BaseLocalizationString + ".reset_session").localized
    }
    

    private static func localizedDevice(_ device: UserClient?) -> String {
        return (BaseLocalizationString + ".otherDevice_part").localized(args: device?.remoteIdentifier ?? "-")
    }

}

class ConversationNewDeviceSystemMessageCellDescription: ConversationMessageCellDescription {
    
    typealias View = NewDeviceSystemMessageCell
    let configuration: View.Configuration
    
    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 0
    
    let isFullWidth: Bool = true
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = false
    
    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil
    
    init(message: ZMConversationMessage, systemMessageData: ZMSystemMessageData, conversation: ZMConversation) {
        configuration = ConversationNewDeviceSystemMessageCellDescription.configuration(for: systemMessageData, in: conversation)
        actionController = nil
    }
    
    struct TextAttributes {
        let senderAttributes : [NSAttributedString.Key: AnyObject]
        let startedUsingAttributes : [NSAttributedString.Key: AnyObject]
        let linkAttributes : [NSAttributedString.Key: AnyObject]
        
        init(boldFont: UIFont, normalFont: UIFont, textColor: UIColor, link: URL) {
            senderAttributes = [.font: boldFont, .foregroundColor: textColor]
            startedUsingAttributes = [.font: normalFont, .foregroundColor: textColor]
            linkAttributes = [.font: normalFont, .link: link as AnyObject]
        }
    }
    
    private static func configuration(for systemMessage: ZMSystemMessageData, in conversation: ZMConversation) -> View.Configuration {
        
        let textAttributes = TextAttributes(boldFont: .mediumSemiboldFont, normalFont: .mediumFont, textColor: UIColor.dynamic(scheme: .title), link: View.userClientURL)
        let clients = systemMessage.clients.compactMap ({ $0 as? UserClientType })
        let users = systemMessage.users.sorted(by: { (a: ZMUser, b: ZMUser) -> Bool in
            a.displayName.compare(b.displayName) == ComparisonResult.orderedAscending
        })
        
        if !systemMessage.addedUsers.isEmpty {
            return configureForAddedUsers(in: conversation, attributes: textAttributes)
        } else if systemMessage.systemMessageType == .reactivatedDevice {
            return configureForReactivatedSelfClient(ZMUser.selfUser(), attributes: textAttributes)
        } else if let user = users.first , user.isSelfUser && systemMessage.systemMessageType == .usingNewDevice {
            return configureForNewCurrentDeviceOfSelfUser(user, attributes: textAttributes)
        } else if users.count == 1, let user = users.first , user.isSelfUser {
            return configureForNewClientOfSelfUser(user, clients: clients, attributes: textAttributes)
        } else {
            return configureForOtherUsers(users, conversation: conversation, clients: clients, attributes: textAttributes)
        }
    }
    
    private static var verifiedIcon: UIImage {
        return WireStyleKit.imageOfShieldnotverified
    }

    private static var exclamationMarkIcon: UIImage {
        return StyleKitIcon.exclamationMark.makeImage(size: 16, color: .vividRed)
    }
    
    private static func configureForReactivatedSelfClient(_ selfUser: ZMUser, attributes: TextAttributes) -> View.Configuration {
        let deviceString = NSLocalizedString("content.system.this_device", comment: "")
        let fullString  = String(format: NSLocalizedString("content.system.reactivated_device", comment: ""), deviceString) && attributes.startedUsingAttributes
        let attributedText = fullString.setAttributes(attributes.linkAttributes, toSubstring: deviceString)
        
        return View.Configuration(attributedText: attributedText, icon: exclamationMarkIcon, linkTarget: .user(selfUser))
    }
    
    private static func configureForNewClientOfSelfUser(_ selfUser: ZMUser, clients: [UserClientType], attributes: TextAttributes) -> View.Configuration {
        let isSelfClient = clients.first?.isEqual(ZMUserSession.shared()?.selfUserClient()) ?? false
        let senderName = NSLocalizedString("content.system.you_started", comment: "") && attributes.senderAttributes
        let startedUsingString = NSLocalizedString("content.system.started_using", comment: "") && attributes.startedUsingAttributes
        let userClientString = NSLocalizedString("content.system.new_device", comment: "") && attributes.linkAttributes
        let attributedText = senderName + "general.space_between_words".localized + startedUsingString + "general.space_between_words".localized + userClientString
        
        return View.Configuration(attributedText: attributedText, icon: isSelfClient ? nil : verifiedIcon, linkTarget: .user(selfUser))
    }
    
    private static func configureForNewCurrentDeviceOfSelfUser(_ selfUser: ZMUser, attributes: TextAttributes) -> View.Configuration {
        let senderName = NSLocalizedString("content.system.you_started", comment: "") && attributes.senderAttributes
        let startedUsingString = NSLocalizedString("content.system.started_using", comment: "") && attributes.startedUsingAttributes
        let userClientString = NSLocalizedString("content.system.this_device", comment: "") && attributes.linkAttributes
        let attributedText = senderName + "general.space_between_words".localized + startedUsingString + "general.space_between_words".localized + userClientString
        
        return View.Configuration(attributedText: attributedText, icon: nil, linkTarget: .user(selfUser))
    }
    
    private static func configureForOtherUsers(_ users: [ZMUser], conversation: ZMConversation, clients: [UserClientType], attributes: TextAttributes) -> View.Configuration {
        let displayNamesOfOthers = users.filter {!$0.isSelfUser }.compactMap {$0.displayName as String}
        let firstTwoNames = displayNamesOfOthers.prefix(2)
        let senderNames = firstTwoNames.joined(separator: ", ")
        let additionalSenderCount = max(displayNamesOfOthers.count - 1, 1)
        
        // %@ %#@d_number_of_others@ started using %#@d_new_devices@
        let senderNamesString = NSString(format: NSLocalizedString("content.system.people_started_using", comment: "") as NSString,
                                         senderNames,
                                         additionalSenderCount,
                                         clients.count) as String
        
        let userClientString = NSString(format: NSLocalizedString("content.system.new_devices", comment: "") as NSString, clients.count) as String
        
        var attributedSenderNames = NSAttributedString(string: senderNamesString, attributes: attributes.startedUsingAttributes)
        attributedSenderNames = attributedSenderNames.setAttributes(attributes.senderAttributes, toSubstring: senderNames)
        attributedSenderNames = attributedSenderNames.setAttributes(attributes.linkAttributes, toSubstring: userClientString)
        let attributedText = attributedSenderNames

        var linkTarget: View.LinkTarget
        if let user = users.first, users.count == 1 {
            linkTarget = .user(user)
        } else {
            linkTarget = .conversation(conversation)
        }
       
        return View.Configuration(attributedText: attributedText, icon: verifiedIcon, linkTarget: linkTarget)
    }
    
    private static func configureForAddedUsers(in conversation: ZMConversation, attributes: TextAttributes) -> View.Configuration {
        let attributedNewUsers = NSAttributedString(string: "content.system.new_users".localized, attributes: attributes.startedUsingAttributes)
        let attributedLink = NSAttributedString(string: "content.system.verify_devices".localized, attributes: attributes.linkAttributes)
        let attributedText = attributedNewUsers + " " + attributedLink
        
        return View.Configuration(attributedText: attributedText, icon: verifiedIcon, linkTarget: .conversation(conversation))
    }
    
}

