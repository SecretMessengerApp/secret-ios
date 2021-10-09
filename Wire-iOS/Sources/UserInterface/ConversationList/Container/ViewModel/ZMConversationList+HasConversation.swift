

import Foundation

extension ZMConversationList {
    static var hasConversations: Bool {
        guard let session = ZMUserSession.shared() else { return false }

        let conversationsCount = ZMConversationList.conversations(inUserSession: session).count + ZMConversationList.pendingConnectionConversations(inUserSession: session).count
        return conversationsCount > 0
    }
}

///TODO: move to DM
extension ZMConversationList: ConversationListHelperType {
    static var hasArchivedConversations: Bool {
        guard let session = ZMUserSession.shared() else { return false }

        return ZMConversationList.conversations(inUserSession: session).count > 0
    }
}

///TODO: retire this static helper, refactor as  ZMUserSession's property
protocol ConversationListHelperType {
    static var hasArchivedConversations: Bool { get }
}
