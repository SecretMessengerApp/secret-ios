

enum ConversationActionType {

    case none, started(withName: String?), added(herself: Bool), removed, left, teamMemberLeave
    
    /// Some actions only involve the sender, others involve other users too.
    var involvesUsersOtherThanSender: Bool {
        switch self {
        case .left, .teamMemberLeave, .added(herself: true): return false
        default:                                             return true
        }
    }
    
    var allowsCollapsing: Bool {
        // Don't collapse when removing participants, since the collapsed
        // link is only used for participants in the conversation.
        switch self {
        case .removed:  return false
        default:        return true
        }
    }

    func image(with color: UIColor) -> UIImage {
        let icon: StyleKitIcon
        switch self {
        case .started, .none:                   icon = .conversation
        case .added:                            icon = .plus
        case .removed, .left, .teamMemberLeave: icon = .minus
        }
        
        return icon.makeImage(size: .tiny, color: color)
    }
}

extension ZMConversationMessage {
    var actionType: ConversationActionType {
        guard let systemMessage = systemMessageData else { return .none }
        switch systemMessage.systemMessageType {
        case .participantsRemoved:  return systemMessage.userIsTheSender ? .left : .removed
        case .participantsAdded:    return .added(herself: systemMessage.userIsTheSender)
        case .newConversation:      return .started(withName: systemMessage.text)
        case .teamMemberLeave:      return .teamMemberLeave
        default:                    return .none
        }
    }
}

class ParticipantsCellViewModel {
    
    private typealias NameList = ParticipantsStringFormatter.NameList
    static let showMoreLinkURL = NSURL(string: "action://show-all")!
    
    let font, boldFont, largeFont: UIFont?
    let textColor, iconColor: UIColor?
    let message: ZMConversationMessage
    
    private var action: ConversationActionType {
        return message.actionType
    }
    
    private var maxShownUsers: Int {
        return isSelfIncludedInUsers ? 16 : 17
    }
    
    private var maxShownUsersWhenCollapsed: Int {
        return isSelfIncludedInUsers ? 14 : 15
    }
    
    var showInviteButton: Bool {
        guard case .started = action, let conversation = message.conversation else { return false }
        return conversation.canManageAccess && conversation.allowGuests
    }
    
    var showServiceUserWarning: Bool {
        guard case .added = action, let systemMessage = message as? ZMSystemMessage, let conversation = message.conversation else { return false }
        let selfAddedToServiceConversation = systemMessage.users.any(\.isSelfUser) && conversation.areServicesPresent
        let serviceAdded = systemMessage.users.any(\.isServiceUser)
        return selfAddedToServiceConversation || serviceAdded
    }
    
    /// Users displayed in the system message, up to 17 when not collapsed
    /// but only 15 when there are more than 15 users and we collapse them.
    lazy var shownUsers: [ZMUser] = {
        let users = sortedUsersWithoutSelf
        let boundary = users.count > maxShownUsers && action.allowsCollapsing ? maxShownUsersWhenCollapsed : users.count
        let result = users[..<boundary]
        return result + (isSelfIncludedInUsers ? [.selfUser()] : [])
    }()
    
    /// Users not displayed in the system message but collapsed into a link.
    /// E.g. `and 5 others`.
    private lazy var collapsedUsers: [ZMUser] = {
        let users = sortedUsersWithoutSelf
        guard users.count > maxShownUsers, action.allowsCollapsing else { return [] }
        return Array(users.dropFirst(maxShownUsersWhenCollapsed))
    }()
    
    /// The users to display when opening the participants details screen.
    var selectedUsers: [ZMUser] {
        switch action {
        case .added: return sortedUsers
        default: return []
        }
    }
    
    lazy var isSelfIncludedInUsers: Bool = {
        return sortedUsers.any(\.isSelfUser)
    }()
    
    /// The users involved in the conversation action sorted alphabetically by
    /// name.
    lazy var sortedUsers: [ZMUser] = {
        guard let sender = message.sender else { return [] }
        guard action.involvesUsersOtherThanSender else { return [sender] }
        guard let systemMessage = message.systemMessageData else { return [] }
        return systemMessage.users.subtracting([sender]).sorted { name(for: $0) < name(for: $1) }
    }()

    init(
        font: UIFont?,
        boldFont: UIFont?,
        largeFont: UIFont?,
        textColor: UIColor?,
        iconColor: UIColor?,
        message: ZMConversationMessage
        ) {
        self.font = font
        self.boldFont = boldFont
        self.largeFont = largeFont
        self.textColor = textColor
        self.iconColor = iconColor
        self.message = message
    }
    
    lazy var sortedUsersWithoutSelf: [ZMUser] = {
        return sortedUsers.filter { !$0.isSelfUser }
    }()

    private func name(for user: ZMUser) -> String {
        if user.isSelfUser {
            return "content.system.you_\(grammaticalCase(for: user))".localized
        }
        return user.displayName(in: message.conversation)
    }
    
    private func name(for userID: String, userName: String) -> String {
        if let selfID = ZMUser.selfUser()?.remoteIdentifier.transportString(),
            selfID == userID {
            return "content.system.you_\(grammaticalCase(for: userID))".localized
        }
        return userName
    }
    
    private var nameList: NameList {
        var userNames: [String] = []
        if let systemMessage = message.systemMessageData,
            message.conversation?.conversationType == .hugeGroup,
            systemMessage.systemMessageType == .participantsAdded || systemMessage.systemMessageType == .participantsRemoved,
            let ids = systemMessage.userIDs?.array,
            let names = systemMessage.userNames,
            names.count > 0
        {
            for (i, userID) in ids.enumerated() {
                if names.count > i {
                    userNames.append(self.name(for: userID as! String, userName: names[i]))
                }
            }
        } else {
           userNames = shownUsers.map { self.name(for: $0) }
        }
        return NameList(names: userNames, collapsed: collapsedUsers.count, selfIncluded: isSelfIncludedInUsers)
    }
    
    /// The user will, depending on the context, be in a specific case within the
    /// sentence. This is important for localization of "you".
    private func grammaticalCase(for user: ZMUser) -> String {
        // user is always the subject
        if user == message.sender { return "nominative" }
        // "started with ... user"
        if case .started = action { return "dative" }
        return "accusative"
    }
    private func grammaticalCase(for userID: String) -> String {
        if let senderID = message.sender?.remoteIdentifier.transportString(),
            senderID == userID { return "nominative" }
        if case .started = action { return "dative" }
        return "accusative"
    }
    
    // ------------------------------------------------------------
    
    func image() -> UIImage? {
        if let iconcolor = iconColor {
            return action.image(with: iconcolor)
        }
        return nil
    }
    
    func attributedHeading() -> NSAttributedString? {
        guard
            case let .started(withName: conversationName?) = action,
            let sender = message.sender,
            let formatter = formatter(for: message)
            else { return nil }
        
        let senderName = name(for: sender).capitalized
        return formatter.heading(senderName: senderName, senderIsSelf: sender.isSelfUser, convName: conversationName)
    }

    func attributedTitle() -> NSAttributedString? {
        guard
            let sender = message.sender,
            let formatter = formatter(for: message)
            else { return nil }
        
        let senderName = name(for: sender).capitalized
        
        if action.involvesUsersOtherThanSender {
            var namesList : NameList
            if message.conversation?.isVisibleForMemberChange ?? false ||
                message.conversation?.creator.isSelfUser ?? false ||
                message.conversation?.manager?.contains(ZMUser.selfUser()?.remoteIdentifier.transportString() ?? "") ?? false { //ruguo
                namesList = nameList
            } else {
                if shownUsers.contains(ZMUser.selfUser()) ||
                    message.systemMessageData?.userIDs?.contains(ZMUser.selfUser()?.remoteIdentifier.transportString() ?? "") ?? false {
                    let userNames = [self.name(for: ZMUser.selfUser())]
                    namesList = NameList(names: userNames, collapsed: collapsedUsers.count, selfIncluded: isSelfIncludedInUsers)
                } else {
                    namesList = nameList
                }
            }
            return formatter.title(senderName: senderName, senderIsSelf: sender.isSelfUser, names: namesList)
        } else {
            return formatter.title(senderName: senderName, senderIsSelf: sender.isSelfUser)
        }
    }
    
    func warning() -> String? {
        guard showServiceUserWarning else { return nil }
        return "content.system.services.warning".localized
    }
    
    private func formatter(for message: ZMConversationMessage) -> ParticipantsStringFormatter? {
        guard let font = font, let boldFont = boldFont,
            let largeFont = largeFont, let textColor = textColor
            else { return nil }
        
        return ParticipantsStringFormatter(
            message: message, font: font, boldFont: boldFont,
            largeFont: largeFont, textColor: textColor
        )
    }
}
