
import Foundation

extension ZMConversationMessage {

    func formattedOriginalReceivedDate() -> String? {
        guard let timestamp = self.serverTimestamp else {
            return nil
        }

        let formattedDate: String

        if Calendar.current.isDateInToday(timestamp) {
            formattedDate = shortTimeFormatter.string(from: timestamp)
            return "content.message.reply.original_timestamp.time".localized(args: formattedDate)
        } else {
            formattedDate = shortDateFormatter.string(from: timestamp)
            return "content.message.reply.original_timestamp.date".localized(args: formattedDate)
        }
    }

    func formattedReceivedDate() -> String? {
        return serverTimestamp.map(formattedDate)
    }

    func formattedEditedDate() -> String? {
        return updatedAt.map(formattedDate)
    }

    func formattedDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return shortTimeFormatter.string(from: date)
        } else {
            return shortDateTimeFormatter.string(from: date)
        }
    }

    func formattedAccessibleMessageDetails() -> String? {
        guard let serverTimestamp = self.serverTimestamp else {
            return nil
        }

        let formattedTimestamp = spellOutDateTimeFormatter.string(from: serverTimestamp)
        let sendDate = "message_details.subtitle_send_date".localized(args: formattedTimestamp)

        var accessibleMessageDetails = sendDate

        if let editTimestamp = self.updatedAt {
            let formattedEditTimestamp = spellOutDateTimeFormatter.string(from: editTimestamp)
            let editDate = "message_details.subtitle_edit_date".localized(args: formattedEditTimestamp)
            accessibleMessageDetails += ("\n" + editDate)
        }

        return accessibleMessageDetails
    }

}

extension ZMSystemMessageData {

    func callDurationString() -> String? {
        guard systemMessageType == .performedCall, duration > 0 else { return nil }
        return Message.callDurationFormatter.string(from: duration)
    }

}


private extension ZMConversationMessage {
    
    var shortTimeFormatter: DateFormatter {
        let formatter = Message.shortTimeFormatter
        formatter.locale = Language.locale
        return formatter
    }
    
    var shortDateFormatter: DateFormatter {
        let formatter = Message.shortDateFormatter
        formatter.locale = Language.locale
        return formatter
    }
    
    var shortDateTimeFormatter: DateFormatter {
        let formatter = Message.shortDateTimeFormatter
        formatter.locale = Language.locale
        return formatter
    }
    
    var spellOutDateTimeFormatter: DateFormatter {
        let formatter = Message.spellOutDateTimeFormatter
        formatter.locale = Language.locale
        return formatter
    }
}
