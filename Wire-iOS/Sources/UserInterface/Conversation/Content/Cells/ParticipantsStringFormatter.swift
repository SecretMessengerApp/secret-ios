//
import Foundation

private typealias Attributes = [NSAttributedString.Key : AnyObject]

private extension ConversationActionType {
    func formatKey(senderIsSelfUser: Bool) -> String {
        switch self {
        case .left: return localizationKey(with: "left", senderIsSelfUser: senderIsSelfUser)
        case .added(herself: true): return "content.system.conversation.guest.joined"
        case .added(herself: false): return localizationKey(with: "added", senderIsSelfUser: senderIsSelfUser)
        case .removed: return localizationKey(with: "removed", senderIsSelfUser: senderIsSelfUser)
        case .started(withName: .none), .none: return localizationKey(with: "started", senderIsSelfUser: senderIsSelfUser)
        case .started(withName: .some): return "content.system.conversation.with_name.participants"
        case .teamMemberLeave: return "content.system.conversation.team.member-leave"
        }
    }
    
    private func localizationKey(with pathComponent: String, senderIsSelfUser: Bool) -> String {
        let senderPath = senderIsSelfUser ? "you" : "other"
        return "content.system.conversation.\(senderPath).\(pathComponent)"
    }
}

/// This class assists in applying string attributes to localized strings.
/// The issue with localized strings is that you can not pass attributed
/// strings as arguments to format strings, therefore the styling must take
/// place after localization. This is especially difficult when the argument
/// requires multiple attributes in various parts of the string. This data
/// structure keeps track of which string components should be applied with
/// which attributes. Then, given an attributed string, these attributes are
/// applied to their corresponding component.
private class FormatSequence {

    typealias SubstringAttrs = (substring: String, attrs: Attributes)
    var string = String()
    var componentAttributes = [SubstringAttrs]()
    
    /// Append a component string with the given attributes.
    func append(_ component: String, with attrs: Attributes) {
        string.append(component)
        define(attrs, forComponent: component)
    }
    
    /// Define the attribute to be applied for the given substring.
    func define(_ attrs: Attributes, forComponent string: String) {
        componentAttributes.append(SubstringAttrs(string, attrs))
    }
    
    /// Apply all attributes for their corresponding components to the given
    /// attributed string.
    func applyComponentAttributes(to attributedString: NSAttributedString) -> NSAttributedString {
        let mutableCopy = NSMutableAttributedString(attributedString: attributedString)
        componentAttributes.forEach { mutableCopy.addAttributes($0.attrs, to: $0.substring) }
        return mutableCopy
    }
}

class ParticipantsStringFormatter {

    private struct Key {
        static let youStartedTheConversation = "content.system.conversation.with_name.title-you"
        static let xStartedTheConversation = "content.system.conversation.with_name.title"
        static let xOthers = "content.system.started_conversation.truncated_people.others"
        static let andX = "content.system.started_conversation.truncated_people"
        static let with = "content.system.conversation.with_name.participants"
        static let xAndY = "content.system.participants_1_other"
        static let completeTeam = "content.system.started_conversation.complete_team"
        static let completeTeamWithGuests = "content.system.started_conversation.complete_team.guests"
    }
    
    struct NameList {
        let names: [String]
        let collapsed: Int
        let selfIncluded: Bool
        
        var totalUsers: Int {
            return names.count + collapsed
        }
    }

    private let message: ZMConversationMessage
    private let font, boldFont, largeFont: UIFont
    private let textColor: UIColor
    
    private var normalAttributes: Attributes {
        return [.font: font, .foregroundColor: textColor]
    }
    
    private var boldAttributes: Attributes {
        return [.font: boldFont, .foregroundColor: textColor]
    }
    
    private var largeAttributes: Attributes {
        return [.font: largeFont, .foregroundColor: textColor]
    }
    
    private var linkAttributes: Attributes {
        return [.link: ParticipantsCellViewModel.showMoreLinkURL]
    }
    
    init(message: ZMConversationMessage, font: UIFont = .mediumFont, boldFont: UIFont = .mediumSemiboldFont, largeFont: UIFont = .largeSemiboldFont, textColor: UIColor = .dynamic(scheme: .title)) {
        self.message = message
        self.font = font
        self.boldFont = boldFont
        self.largeFont = largeFont
        self.textColor = textColor
    }
    
    /// This is only used when a conversation (with a name) is started.
    func heading(senderName: String, senderIsSelf: Bool, convName: String) -> NSAttributedString {
        // "You/Bob started the conversation"
        let key = senderIsSelf ? Key.youStartedTheConversation : Key.xStartedTheConversation
        var text = key.localized(args: senderName) && font
        text = senderIsSelf ? text : text.adding(font: boldFont, to: senderName)
        // "Italy Trip"
        let title = convName.attributedString && largeFont
        return [text, title].joined(separator: "\n".attributedString) && textColor && .lineSpacing(4)
    }
    
    /// Title when the subject (sender) is performing the action alone.
    func title(senderName: String, senderIsSelf: Bool) -> NSAttributedString? {
        switch message.actionType {
        case .left, .teamMemberLeave, .added(herself: true):
            let formatKey = message.actionType.formatKey
            let title = formatKey(senderIsSelf).localized(args: senderName) && font && textColor
            return senderIsSelf ? title : title.adding(font: boldFont, to: senderName)
        default: return nil
        }
    }
    
    /// Title when the subject (sender) performing the action on objects (names).
    func title(senderName: String, senderIsSelf: Bool, names: NameList) -> NSAttributedString? {
        guard !names.names.isEmpty else { return nil }
        
        var result: NSAttributedString
        let formatKey = message.actionType.formatKey
        let nameSequence = format(names)
        
        switch message.actionType {
        case .removed, .added(herself: false), .started(withName: .none):
            result = formatKey(senderIsSelf).localized(args: senderName, nameSequence.string) && font && textColor
            if !senderIsSelf { result = result.adding(font: boldFont, to: senderName) }
            
        case .started(withName: .some):
            result = "\(Key.with.localized) \(nameSequence.string)" && font && textColor
            
        default: return nil
        }
        
        return nameSequence.applyComponentAttributes(to: result)
    }
    
    /// Returns a `FormatSequence` describing a list of names. The list is comprised
    /// of usernames for shown users (complete with punctuation) and a count string
    /// for collapsed users, if any. E.g: "x, y, z, and 3 others"
    private func format(_ nameList: NameList) -> FormatSequence {
        guard !nameList.names.isEmpty else { preconditionFailure() }
        let result = FormatSequence()
        
        // all team users added?
        if let linkText = linkTextForWholeTeam(nameList) {
            result.append(linkText, with: linkAttributes)
            return result
        }
        
        let names = nameList.names
        let attrsForLastName = nameList.selfIncluded ? normalAttributes : boldAttributes
        
        switch names.count {
        case 1:
            // "x"
            result.append(names.last!, with: attrsForLastName)
        case 2:
            // "x and y"
            let part = Key.xAndY.localized(args: names.first!, names.last!)
            result.append(part, with: normalAttributes)
            result.define(boldAttributes, forComponent: names.first!)
            result.define(attrsForLastName, forComponent: names.last!)
        default:
            // "x, y, "
            result.append(names.dropLast().map { $0 + ", " }.joined(), with: boldAttributes)
            
            if nameList.collapsed > 0 {
                // "you/z, "
                result.append(names.last! + ", ", with: attrsForLastName)
                // "and X others
                let linkText = Key.xOthers.localized(args: "\(nameList.collapsed)")
                let linkPart = Key.andX.localized(args: linkText)
                result.append(linkPart, with: normalAttributes)
                result.define(linkAttributes, forComponent: linkText)
            } else {
                // "and you/z"
                let lastPart = Key.andX.localized(args: names.last!)
                result.append(lastPart, with: normalAttributes)
                result.define(attrsForLastName, forComponent: names.last!)
            }
        }
        
        return result
    }
    
    private func linkTextForWholeTeam(_ nameList: NameList) -> String? {
        guard
            let systemMessage = message as? ZMSystemMessage,
            systemMessage.allTeamUsersAdded,
            message.conversation?.canManageAccess ?? false
            else { return nil }
        
        // we only collapse whole team if there are more than 10 participants
        guard nameList.totalUsers + Int(systemMessage.numberOfGuestsAdded) > 10 else {
            return nil
        }
        
        if systemMessage.numberOfGuestsAdded > 0 {
            return Key.completeTeamWithGuests.localized(args: String(systemMessage.numberOfGuestsAdded))
        } else {
            return Key.completeTeam.localized
        }
    }
}
