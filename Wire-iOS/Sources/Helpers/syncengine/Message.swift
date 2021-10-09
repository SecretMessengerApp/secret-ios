
import Foundation

extension Message {
    @objc(shouldShowDestructionCountdown:)
    public static func shouldShowDestructionCountdown(_ message: ZMConversationMessage) -> Bool {
        return message.shouldShowDestructionCountdown
    }
}

extension ZMConversationMessage {
    var shouldShowDestructionCountdown: Bool {
        return !self.hasBeenDeleted &&
               self.isEphemeral &&
               !self.isObfuscated &&
               !self.isKnock
    }
}

extension Message {
    
    static var shortTimeFormatter: DateFormatter = {
        var shortTimeFormatter = DateFormatter()
        shortTimeFormatter.dateStyle = .none
        shortTimeFormatter.timeStyle = .short
        return shortTimeFormatter
    }()
    
    static let shortDateFormatter : DateFormatter = {
        var shortDateFormatter = DateFormatter()
        shortDateFormatter.dateStyle = .short
        shortDateFormatter.timeStyle = .none
        return shortDateFormatter
    }()
    
    static let spellOutDateTimeFormatter: DateFormatter = {
        var longDateFormatter = DateFormatter()
        longDateFormatter.dateStyle = .long
        longDateFormatter.timeStyle = .short
        longDateFormatter.doesRelativeDateFormatting = true
        return longDateFormatter
    }()
    
    static let shortDateTimeFormatter: DateFormatter = {
        var longDateFormatter = DateFormatter()
        longDateFormatter.dateStyle = .short
        longDateFormatter.timeStyle = .short
        return longDateFormatter
    }()
    
}
