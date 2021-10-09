
import Foundation

// Describes the icon to be shown for the conversation in the list.
enum ConversationStatusIcon: Equatable {
    case pendingConnection
    
    case typing
    
    case unreadMessages(count: Int)
    case unreadPing
    case missedCall
    case mention
    case reply

    case silenced
    
    case playingMedia(isPause: Bool)
    
    case activeCall(showJoin: Bool)
}

// Describes the status of the conversation.
struct ConversationStatus {
    let isGroup: Bool
    
    let hasMessages: Bool
    let hasUnsentMessages: Bool
    
    //let messagesRequiringAttention: [ZMConversationMessage]
    let messagesRequiringAttentionByType: [StatusMessageType: UInt]
    let isTyping: Bool
    let mutedMessageTypes: MutedMessageTypes
    let isOngoingCall: Bool
    let isBlocked: Bool
    let isSelfAnActiveMember: Bool
    let hasSelfMention: Bool
    let hasSelfReply: Bool
    let hasUnreadMessages: Bool
    let unreadMessagesCount: UInt
    let lastMessage: ZMConversationMessage?
}

// Describes the conversation message.
enum StatusMessageType: Int {
    case jsonText
    case mention
    case reply
    case missedCall
    case knock
    case text
    case link
    case image
    case location
    case audio
    case video
    case file
    case addParticipants
    case removeParticipants
    case newConversation
    case performedCall
    case convservice
    
    case allDisableSendMsg
    case deletedForEveryOne
    
    case illegal
}

extension StatusMessageType {
    /// Types of statuses that can be included in a status summary.
    static let summaryTypes: [StatusMessageType] = [.jsonText, .mention, .reply, .missedCall, .performedCall, .knock, .text, .link, .image, .location, .audio, .video, .file, .convservice, .allDisableSendMsg, .deletedForEveryOne]

    var parentSummaryType: StatusMessageType? {
        switch self {
        case .link, .image, .location, .audio, .video, .file, .convservice: return .text
        default: return nil
        }
    }

    private static let conversationSystemMessageTypeToStatusMessageType: [ZMSystemMessageType: StatusMessageType] = [
        .participantsAdded: .addParticipants,
        .participantsRemoved: .removeParticipants,
        .missedCall: .missedCall,
        .newConversation: .newConversation,
        .performedCall: .performedCall,
        .serviceMessage: .convservice,
        .allDisableSendMsg : .allDisableSendMsg,
        .messageDeletedForEveryone :.deletedForEveryOne
    ]
    
    init?(message: ZMConversationMessage) {
        if message.isIllegal {
            self = .illegal
        } else if message.isText, let textMessage = message.textMessageData {
            if textMessage.isMentioningSelf {
                self = .mention
            }
            else if textMessage.isQuotingSelf {
                self = .reply
            }
            else if let _ = textMessage.linkPreview {
                self = .link
            }
            else {
                self = .text
            }
        }
        else if message.isJsonText {
            self = .jsonText
        }
        else if message.isImage {
            self = .image
        }
        else if message.isLocation {
            self = .location
        }
        else if message.isAudio {
            self = .audio
        }
        else if message.isVideo {
            self = .video
        }
        else if message.isFile {
            self = .file
        }
        else if message.isKnock {
            self = .knock
        }
        else if message.isDeletion {
            self = .deletedForEveryOne
        }
        else if message.isSystem, let system = message.systemMessageData {
            if let statusMessageType = StatusMessageType.conversationSystemMessageTypeToStatusMessageType[system.systemMessageType] {
                self = statusMessageType
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
}

// Describes object that is able to match and describe the conversation.
// Provides rich description and status icon.
protocol ConversationStatusMatcher {
    func isMatching(with status: ConversationStatus) -> Bool
    func description(with status: ConversationStatus, conversation: ZMConversation) -> NSAttributedString?
    func icon(with status: ConversationStatus, conversation: ZMConversation) -> ConversationStatusIcon?
    
    // An array of matchers that are compatible with the current one. Leads to display the description of all matching 
    // in one row, like "description1 | description2"
    var combinesWith: [ConversationStatusMatcher] { get }
}

protocol TypedConversationStatusMatcher: ConversationStatusMatcher {
    var matchedTypes: [StatusMessageType] { get }
}

extension TypedConversationStatusMatcher {
    func isMatching(with status: ConversationStatus) -> Bool {
        guard let message = status.lastMessage,
            let messageType = StatusMessageType(message: message) else {
                return false
        }
        return matchedTypes.contains(messageType)
    }
}

extension ConversationStatusMatcher {
    func icon(with status: ConversationStatus, conversation: ZMConversation) -> ConversationStatusIcon? {
        return nil
    }
    
    func addEmphasis(to string: NSAttributedString, for substring: String) -> NSAttributedString {
        return string.setAttributes(type(of: self).emphasisStyle, toSubstring: substring)
    }
}


final class ContentSizeCategoryUpdater {
    private let callback: () -> ()
    private var observer: NSObjectProtocol!
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    init(callback: @escaping () -> ()) {
        self.callback = callback
        callback()
        self.observer = NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification,
                                                               object: nil,
                                                               queue: nil) { [weak self] _ in
                                                                self?.callback()
        }
    }
}

final class ConversationStatusStyle {
    private(set) var regularStyle: [NSAttributedString.Key: AnyObject] = [:]
    private(set) var emphasisStyle: [NSAttributedString.Key: AnyObject] = [:]
    private var contentSizeStyleUpdater: ContentSizeCategoryUpdater!
    
    init() {
        contentSizeStyleUpdater = ContentSizeCategoryUpdater { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.regularStyle = [.font: FontSpec(.medium, .none).font!,
                                 .foregroundColor: UIColor(white:0.0, alpha:0.64)]
            self.emphasisStyle = [.font: FontSpec(.medium, .medium).font!,
                                  .foregroundColor: UIColor(white:0.0, alpha:0.64)]
        }
    }
}

fileprivate let statusStyle = ConversationStatusStyle()

extension ConversationStatusMatcher {
    static var regularStyle: [NSAttributedString.Key: AnyObject] {
        return statusStyle.regularStyle
    }
    
    static var emphasisStyle: [NSAttributedString.Key: AnyObject] {
        return statusStyle.emphasisStyle
    }
}

// Accessors for ObjC
extension ZMConversation {
    static func statusRegularStyle() -> [NSAttributedString.Key: AnyObject] {
        return statusStyle.regularStyle
    }
    
    static func statusEmphasisStyle() -> [NSAttributedString.Key: AnyObject] {
        return statusStyle.emphasisStyle
    }
}


// "You left"
final internal class SelfUserLeftMatcher: ConversationStatusMatcher {
    func isMatching(with status: ConversationStatus) -> Bool {
        return !status.hasMessages && status.isGroup && !status.isSelfAnActiveMember
    }
    
    func description(with status: ConversationStatus, conversation: ZMConversation) -> NSAttributedString? {
        return "conversation.status.you_left".localized && type(of: self).regularStyle
    }
    
    func icon(with status: ConversationStatus, conversation: ZMConversation) -> ConversationStatusIcon? {
        return nil
    }
    
    var combinesWith: [ConversationStatusMatcher] = []
}

// "Blocked"
final internal class BlockedMatcher: ConversationStatusMatcher {
    func isMatching(with status: ConversationStatus) -> Bool {
        return status.isBlocked
    }
    
    func description(with status: ConversationStatus, conversation: ZMConversation) -> NSAttributedString? {
        return "conversation.status.blocked".localized && type(of: self).regularStyle
    }
    
    var combinesWith: [ConversationStatusMatcher] = []
}

// "Active Call"
final internal class CallingMatcher: ConversationStatusMatcher {
    func isMatching(with status: ConversationStatus) -> Bool {
        return status.isOngoingCall
    }
    
    func description(with status: ConversationStatus, conversation: ZMConversation) -> NSAttributedString? {
        if conversation.voiceChannel?.state.canJoinCall == true {
            if let callerDisplayName = conversation.voiceChannel?.initiator?.displayName {
                return "conversation.status.incoming_call".localized(args: callerDisplayName) && type(of: self).regularStyle
            } else {
                return "conversation.status.incoming_call.someone".localized && type(of: self).regularStyle
            }
        }
        return .none
    }
    
    func icon(with status: ConversationStatus, conversation: ZMConversation) -> ConversationStatusIcon? {
        return CallingMatcher.icon(for: conversation.voiceChannel?.state, conversation: conversation)
    }
    
    public static func icon(for state: CallState?, conversation: ZMConversation?) -> ConversationStatusIcon? {
        
        guard let state = state else {
            return nil
        }
        
        if state.canJoinCall {
            return .activeCall(showJoin: true)
        } else if state.isCallOngoing {
            return .activeCall(showJoin: false)
        }
        
        return nil
    }
    
    var combinesWith: [ConversationStatusMatcher] = []
}

// "A, B, C: typing a message..."
final internal class TypingMatcher: ConversationStatusMatcher {
    func isMatching(with status: ConversationStatus) -> Bool {
        return status.isTyping && status.showingAllMessages
    }
    
    func description(with status: ConversationStatus, conversation: ZMConversation) -> NSAttributedString? {
        let statusString: NSAttributedString
        if status.isGroup, let typingUsers = conversation.typingUsers() {
            let typingUsersString = typingUsers.compactMap { $0 as? ZMUser }.map { $0.displayName(in: conversation) }.joined(separator: ", ")
            let resultString = String(format: "conversation.status.typing.group".localized, typingUsersString)
            let intermediateString = NSAttributedString(string: resultString, attributes: type(of: self).regularStyle)
            statusString = self.addEmphasis(to: intermediateString, for: typingUsersString)
        }
        else {
            statusString = "conversation.status.typing".localized && type(of: self).regularStyle
        }
        return statusString
    }
    
    func icon(with status: ConversationStatus, conversation: ZMConversation) -> ConversationStatusIcon? {
        return .typing
    }
    
    var combinesWith: [ConversationStatusMatcher] = []
}

// "Silenced"
final internal class SilencedMatcher: ConversationStatusMatcher {
    func isMatching(with status: ConversationStatus) -> Bool {
        return !status.showingAllMessages
    }
    
    func description(with status: ConversationStatus, conversation: ZMConversation) -> NSAttributedString? {
        return .none
    }
    
    func icon(with status: ConversationStatus, conversation: ZMConversation) -> ConversationStatusIcon? {
        if status.showingOnlyMentionsAndReplies {
            if status.hasSelfMention {
                return .mention
            } else if status.hasSelfReply {
                return .reply
            }
        }

        return .silenced
    }
    
    var combinesWith: [ConversationStatusMatcher] = []
}


extension ConversationStatus {

    var showingAllMessages: Bool {
        return mutedMessageTypes == .none
    }

    var showingOnlyMentionsAndReplies: Bool {
        return mutedMessageTypes == .regular
    }

    var completelyMuted: Bool {
        return mutedMessageTypes == .all
    }
        
    var shouldSummarizeMessages: Bool {
        if completelyMuted {
            // Always summarize for completely muted conversation
            return true
        } else if showingOnlyMentionsAndReplies && !hasSelfMention && !hasSelfReply {
            // Summarize when there is no mention
            return true
        } else if hasSelfMention {
            // Summarize if there is at least one mention and another activity that can be inside a summary
            return StatusMessageType.summaryTypes.reduce(into: UInt(0)) { $0 += (messagesRequiringAttentionByType[$1] ?? 0) } > 1
        } else if hasSelfReply {
            // Summarize if there is at least one reply and another activity that can be inside a summary

            let count = StatusMessageType.summaryTypes.reduce(into: UInt(0)) { $0 += (messagesRequiringAttentionByType[$1] ?? 0) }

            // if all activities are replies, do not summarize
            if messagesRequiringAttentionByType[.reply] == count {
                return false
            } else {
                return count > 1
            }
        } else {
            // Never summarize in other cases
            return false
        }
    }
}


// In silenced "N (text|image|link|...) message, ..."
// In not silenced: "[Sender:] <message text>"
// Ephemeral: "Ephemeral message"
final internal class NewMessagesMatcher: TypedConversationStatusMatcher {
    var matchedTypes: [StatusMessageType] {
        return StatusMessageType.summaryTypes
    }

    let localizationSilencedRootPath = "conversation.silenced.status.message"
    let localizationRootPath = "conversation.status.message"

    let matchedSummaryTypesDescriptions: [StatusMessageType: String] = [
        .mention:    "mention",
        .reply:      "reply",
        .missedCall: "missedcall",
        .knock:      "knock",
        .text:       "generic_message"
    ]

    let matchedTypesDescriptions: [StatusMessageType: String] = [
        .mention:    "mention",
        .reply:      "reply",
        .missedCall: "missedcall",
        .knock:      "knock",
        .text:       "text",
        .link:       "link",
        .image:      "image",
        .location:   "location",
        .audio:      "audio",
        .video:      "video",
        .file:       "file",
        .jsonText:  "jsonText",
        .performedCall:  "performedCall",
        .convservice: "convservice",
        .allDisableSendMsg: "allDisableSendMsg",
        .deletedForEveryOne: "deletedForEveryOne",
        .illegal: "illegal"
    ]
    

    ///
    func dateDescription(with status: ConversationStatus, conversation: ZMConversation) -> NSAttributedString?  {
        if let date = conversation.lastModifiedDate {
            
            let isToday = NSCalendar.current.isDateInToday(date)
            let fmt = DateFormatter()
            
            if isToday {
                fmt.dateFormat = "HH:mm"
            } else {
                fmt.dateFormat = "yyyy-MM-dd"
            }
            return  fmt.string(from: date) && Swift.type(of: self).regularStyle
        }
        else {
            return "" && Swift.type(of: self).regularStyle
        }
    }
    
    func lastMessageDescription(with status: ConversationStatus, conversation: ZMConversation) -> NSAttributedString? {
        guard let message = status.lastMessage,
            let sender = message.sender,
            let type = StatusMessageType(message: message),
            let localizationKey = matchedTypesDescriptions[type] else {
                return "" && Swift.type(of: self).regularStyle
        }
  
        if let serviceMessage = conversation.lastServiceMessage,
            serviceMessage.systemMessage?.serverTimestamp > message.serverTimestamp {
            return (serviceMessage.text ?? "") && Swift.type(of: self).regularStyle
        }
        
        let messageDescription: String
        
        if type == .illegal {
            messageDescription = (localizationRootPath + localizationKey).localized
            return messageDescription && Swift.type(of: self).regularStyle
        }
        
        if message.isEphemeral {
            var typeSuffix = ".ephemeral"
            if type == .mention {
                typeSuffix += status.isGroup ? ".mention.group" : ".mention"
            } else if type == .reply {
                typeSuffix += status.isGroup ? ".reply.group" : ".reply"
            } else if type == .knock {
                typeSuffix += status.isGroup ? ".knock.group" : ".knock"
            } else if status.isGroup {
                typeSuffix += ".group"
            }
            messageDescription = (localizationRootPath + typeSuffix).localized
        } else if message.isJsonText {
            if let jsonString = message.jsonTextMessageData?.jsonMessageText {
                let object = ConversationJSONMessage(jsonString)
                switch object.type {
                case .confirmLinkAddContact, .confirmAddContact:
                    let name = object.dataDictionary?["name"] as? String
                    let nums =  object.dataDictionary?["nums"] as? Int
                    messageDescription = "conversation.groupinvite.invite".localized(args: name ?? "", "\(nums ?? 0)")
                case .inviteGroupMemberVerify:
                    messageDescription = "conversation.groupinvite.statue".localized
                case .expression:
                    messageDescription = "conversation_list.message.expression".localized
                default:
                    messageDescription = ""
                }
            } else {
                messageDescription = ""
            }
            
        } else if message.isSystem {
            if type == .performedCall || type == .missedCall {
                let viewModel = CallCellViewModel(
                    icon: .phone,
                    iconColor: UIColor(for: .strongLimeGreen),
                    systemMessageType: type == .performedCall ? .performedCall : .missedCall,
                    font: .mediumFont,
                    boldFont: .mediumSemiboldFont,
                    textColor: .dynamic(scheme: .title),
                    message: message
                )
                messageDescription = viewModel.attributedTitleForConversationList()?.string ?? ""
            } else if type == .convservice {
                messageDescription = message.systemMessageData?.serviceMessage?.text ?? ""
            } else if type == .deletedForEveryOne {
                messageDescription = "conversion.message.deleted".localized
            } else if type == .allDisableSendMsg {
                let disable = message.systemMessageData?.blockTime?.int64Value == -1
                messageDescription = disable ? "message.disable.all.open".localized : "message.disable.all.close".localized
            } else {
                messageDescription = ""
            }
            
        } else {
            var format = localizationRootPath + "." + localizationKey
            
            if status.isGroup && type == .missedCall {
                format += ".groups"
                return format.localized(args: sender.displayName(in: conversation)) && Swift.type(of: self).regularStyle
            }
            
            messageDescription = String(format: format.localized, message.textMessageData?.messageText ?? "")
        }
        
        if message.isService {
            return messageDescription && Swift.type(of: self).regularStyle
        }
        
        if status.isGroup && !message.isEphemeral {
            return ((sender.displayName(in: conversation) + ": ") && Swift.type(of: self).emphasisStyle) +
                (messageDescription && Swift.type(of: self).regularStyle)
        }
        else {
            return messageDescription && Swift.type(of: self).regularStyle
        }
    }

    func description(with status: ConversationStatus, conversation: ZMConversation) -> NSAttributedString? {
        if status.shouldSummarizeMessages {
            // Get the count of each category we can summarize, and group them under their parent type
            let flattenedCount: [StatusMessageType: UInt] = matchedTypes
                .reduce(into: [StatusMessageType: UInt]()) {
                    guard let count = status.messagesRequiringAttentionByType[$1], count > 0 else {
                        return
                    }

                    if let parentType = $1.parentSummaryType {
                        $0[parentType, default: 0] += count
                    } else {
                        $0[$1, default: 0] += count
                    }
                }

            // For each top-level summary type, generate the subtitle fragment
            var localizedMatchedItems: [String] = flattenedCount.keys.lazy
                .sorted { $0.rawValue < $1.rawValue }
                .reduce(into: []) {
                    guard let count = flattenedCount[$1], let localizationKey = matchedSummaryTypesDescriptions[$1] else {
                        return
                    }
                    let string = String(format: (localizationSilencedRootPath + "." + localizationKey).localized, count)
                    $0.append(string)
                }
            if status.unreadMessagesCount > 0 {
                let unreadMessagesStr = String(format: (localizationSilencedRootPath + ".generic_message").localized, status.unreadMessagesCount)
                localizedMatchedItems.append(unreadMessagesStr)
            } else if localizedMatchedItems.count == 0 {
               
                return lastMessageDescription(with: status, conversation: conversation)
            }

            let resultString = localizedMatchedItems.joined(separator: ", ")
            return resultString.capitalizingFirstLetter() && type(of: self).regularStyle
        }
        else {
            return lastMessageDescription(with: status, conversation: conversation)
        }

    }
    
    func icon(with status: ConversationStatus, conversation: ZMConversation) -> ConversationStatusIcon? {
       
        if status.messagesRequiringAttentionByType.count > 0,
            let lastMessage = status.lastMessage {
            if let textMessageData = lastMessage.textMessageData {
                if textMessageData.isMentioningSelf {
                    return .mention
                } else if textMessageData.isQuotingSelf {
                    return .reply
                }
            }
            if lastMessage.isMissedCall {
                return .missedCall
            }
            else if lastMessage.isKnock {
                return .unreadPing
            }
        }
        if status.unreadMessagesCount > 0 {
            return .unreadMessages(count: Int(status.unreadMessagesCount))
        }
        return nil
    }
    
    var combinesWith: [ConversationStatusMatcher] = []
}

// ! Failed to send
final internal class FailedSendMatcher: ConversationStatusMatcher {
    func isMatching(with status: ConversationStatus) -> Bool {
        return status.hasUnsentMessages
    }
    
    func description(with status: ConversationStatus, conversation: ZMConversation) -> NSAttributedString? {
        return "conversation.status.unsent".localized && type(of: self).regularStyle
    }
    
    var combinesWith: [ConversationStatusMatcher] = []
}

extension ZMUser {
    func nameAsSender(in conversation: ZMConversation) -> String {
        if self.isSelfUser {
            return "conversation.status.you".localized
        }
        else {
            return self.displayName(in: conversation)
        }
    }
}

// "[You|User] [added|removed|left] [_|users|you]"
final internal class GroupActivityMatcher: TypedConversationStatusMatcher {
    let matchedTypes: [StatusMessageType] = [.addParticipants, .removeParticipants]
    
    private func addedString(for messages: [ZMConversationMessage], in conversation: ZMConversation) -> NSAttributedString? {
        if let message = messages.last/*,
           let systemMessage = message.systemMessageData,
           let sender = message.sender,
           !sender.isSelfUser*/ {
        
//            if systemMessage.users.contains(where: { $0.isSelfUser }) {
//                let result = String(format: "conversation.status.you_was_added".localized, sender.displayName(in: conversation)) && type(of: self).regularStyle
//                return self.addEmphasis(to: result, for: sender.displayName(in: conversation))
//            }
       
            let color = UIColor.dynamic(scheme: .title)
            let model = ParticipantsCellViewModel(font: .mediumFont, boldFont: .mediumSemiboldFont, largeFont: .largeSemiboldFont, textColor: color, iconColor: color, message: message)
            return model.attributedTitle()?.string ?? "" && type(of: self).regularStyle
        }
        return .none
    }
    
    private func removedString(for messages: [ZMConversationMessage], in conversation: ZMConversation) -> NSAttributedString? {
        
        if let message = messages.last/*,
           let systemMessage = message.systemMessageData,
           let sender = message.sender,
           !sender.isSelfUser*/{

//            if systemMessage.users.contains(where: { $0.isSelfUser }) {
//                return "conversation.status.you_were_removed".localized && type(of: self).regularStyle
//            }
           
            let color = UIColor.dynamic(scheme: .title)
            let model = ParticipantsCellViewModel(font: .mediumFont, boldFont: .mediumSemiboldFont, largeFont: .largeSemiboldFont, textColor: color, iconColor: color, message: message)
            return model.attributedTitle()?.string ?? "" && type(of: self).regularStyle
        }
        return .none
    }
    
    func description(with status: ConversationStatus, conversation: ZMConversation) -> NSAttributedString? {
        var allStatusMessagesByType: [StatusMessageType: [ZMConversationMessage]] = [:]
        
        self.matchedTypes.forEach { type in
            if let message = status.lastMessage, StatusMessageType(message: message) == type {
                allStatusMessagesByType[type] = [message]
            }
        }
        
        let resultString = [addedString(for: allStatusMessagesByType[.addParticipants] ?? [], in: conversation),
                            removedString(for: allStatusMessagesByType[.removeParticipants] ?? [], in: conversation)].compactMap { $0 }.joined(separator: "; " && type(of: self).regularStyle)
        return resultString
    }
    
    var combinesWith: [ConversationStatusMatcher] = []
    
    func icon(with status: ConversationStatus, conversation: ZMConversation) -> ConversationStatusIcon? {
        if status.unreadMessagesCount > 0 {
            return .unreadMessages(count: Int(status.unreadMessagesCount))
        }
        return nil
    }
    
}

// [Someone] started a conversation
final internal class StartConversationMatcher: TypedConversationStatusMatcher {
    let matchedTypes: [StatusMessageType] = [.newConversation]
    
    func description(with status: ConversationStatus, conversation: ZMConversation) -> NSAttributedString? {
        guard let message = status.lastMessage,
            StatusMessageType(message: message) == .newConversation,
            let sender = message.sender else {
                return .none
        }

        let senderString = sender.displayName(in: conversation)
        let resultString = String(format: "conversation.status.started_conversation".localized, senderString)
        return (resultString && type(of: self).regularStyle).addAttributes(type(of: self).emphasisStyle, toSubstring: senderString)
    }
    
    func icon(with status: ConversationStatus, conversation: ZMConversation) -> ConversationStatusIcon? {
        if status.unreadMessagesCount > 0 {
            return .unreadMessages(count: Int(status.unreadMessagesCount))
        }
        return nil
    }
    
    var combinesWith: [ConversationStatusMatcher] = []
}

// Fallback for empty conversations: showing the handle.
final internal class UnsernameMatcher: ConversationStatusMatcher {
    func isMatching(with status: ConversationStatus) -> Bool {
        return !status.hasMessages
    }
    
    func description(with status: ConversationStatus, conversation: ZMConversation) -> NSAttributedString? {
        guard let connectedUser = conversation.connectedUser,
                let handle = connectedUser.handle else {
            return .none
        }
        
        return "@" + handle && type(of: self).regularStyle
    }
    
    var combinesWith: [ConversationStatusMatcher] = []
}

/*
 Matchers priorities (highest first):
 
 (SelfUserLeftMatcher)
 (Blocked)
 (Calling)
 (Typing)
 (Silenced)
 (New message / call)
 (Unsent message combines with (Group activity), (New message / call), (Silenced))
 (Group activity)
 (Started conversation)
 (Username)
 */
private var allMatchers: [ConversationStatusMatcher] = {
    let silencedMatcher = SilencedMatcher()
    let newMessageMatcher = NewMessagesMatcher()
    let groupActivityMatcher = GroupActivityMatcher()
    
    let failedSendMatcher = FailedSendMatcher()
    failedSendMatcher.combinesWith = [silencedMatcher, newMessageMatcher, groupActivityMatcher]
    
    return [SelfUserLeftMatcher(), BlockedMatcher(), CallingMatcher(), silencedMatcher, TypingMatcher(), failedSendMatcher, newMessageMatcher, groupActivityMatcher, StartConversationMatcher(), UnsernameMatcher()]
}()

extension ConversationStatus {
    func appliedMatchersForDescription(for conversation: ZMConversation) -> [ConversationStatusMatcher] {
        guard let topMatcher = allMatchers.first(where: { $0.isMatching(with: self) && $0.description(with: self, conversation: conversation) != .none }) else {
            return []
        }
        
        return [topMatcher] + topMatcher.combinesWith.filter { $0.isMatching(with: self) && $0.description(with: self, conversation: conversation) != .none }
    }
    
    func appliedMatcherForIcon(for conversation: ZMConversation) -> ConversationStatusMatcher? {
        for matcher in allMatchers.filter({ $0.isMatching(with: self) }) {
            let icon = matcher.icon(with: self, conversation: conversation)
            switch icon {
            case .none:
                break
            default:
                return matcher
            }
        }
        
        return .none
    }
    

    func dateDescription(for conversation: ZMConversation) -> NSAttributedString {
        let msgMatcher = NewMessagesMatcher()
        return msgMatcher.dateDescription(with: self, conversation: conversation) ?? ("" && [:])
    }
    
    func description(for conversation: ZMConversation) -> NSAttributedString {
        let allMatchers = self.appliedMatchersForDescription(for: conversation)
        guard allMatchers.count > 0 else {
            return "" && [:]
        }
        let allStrings = allMatchers.compactMap { $0.description(with: self, conversation: conversation) }
        return allStrings.joined(separator: " | " && CallingMatcher.regularStyle)
    }
    
    func icon(for conversation: ZMConversation) -> ConversationStatusIcon? {
        guard let topMatcher = self.appliedMatcherForIcon(for: conversation) else {
            return nil
        }
        
        return topMatcher.icon(with: self, conversation: conversation)
    }
}

extension ZMConversation {
    
    var status: ConversationStatus {

        
        //var messagesRequiringAttention: [ZMConversationMessage] = []
        var messagesRequiringAttentionByType: [StatusMessageType: UInt] = [:]

        if self.estimatedUnreadSelfMentionCount > 0 {
            messagesRequiringAttentionByType[.mention] = UInt(self.estimatedUnreadSelfMentionCount)
        }
        if self.estimatedUnreadSelfReplyCount > 0 {
            messagesRequiringAttentionByType[.reply] = UInt(self.estimatedUnreadSelfReplyCount)
        }
        if self.lastUnreadKnockDate != nil {
            messagesRequiringAttentionByType[.knock] = 1
        }
        if self.lastUnreadMissedCallDate != nil {
            messagesRequiringAttentionByType[.missedCall] = 1
        }
        
        
        let isOngoingCall: Bool = {
            guard let state = voiceChannel?.state else { return false }
            switch state {
            case .none, .terminating: return false
            case .incoming: return true
            default: return true
            }
        }()
        
        return ConversationStatus(
            isGroup: [.group, .hugeGroup].contains(conversationType),
            hasMessages: estimatedHasMessages,
            hasUnsentMessages: false,
            //messagesRequiringAttention: messagesRequiringAttention,
            messagesRequiringAttentionByType: messagesRequiringAttentionByType,
            isTyping: typingUsers().count > 0,
            mutedMessageTypes: mutedMessageTypes,
            isOngoingCall: isOngoingCall,
            isBlocked: connectedUser?.isBlocked ?? false,
            isSelfAnActiveMember: isSelfAnActiveMember,
            hasSelfMention: estimatedUnreadSelfMentionCount > 0,
            hasSelfReply: estimatedUnreadSelfReplyCount > 0,
            hasUnreadMessages: estimatedUnreadCount > 0,
            unreadMessagesCount: estimatedUnreadCount,
            lastMessage: self.lastConversationMessage
        )
    }
}

