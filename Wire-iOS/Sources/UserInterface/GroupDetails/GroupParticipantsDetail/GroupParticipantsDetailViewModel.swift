
import Foundation

fileprivate extension String {
    var isValidQuery: Bool {
        return !isEmpty && self != "@"
    }
}

class GroupParticipantsDetailViewModel: NSObject, SearchHeaderViewControllerDelegate, ZMConversationObserver {

    var internalParticipants: [UserType]
    var filterQuery: String?
    
    let selectedParticipants: [UserType]
    let conversation: ZMConversation
    var participantsDidChange: (() -> Void)? = nil
    
    fileprivate var token: NSObjectProtocol?

    var indexOfFirstSelectedParticipant: Int? {
        guard let first = selectedParticipants.first as? ZMUser else { return nil }
        return internalParticipants.firstIndex {
            ($0 as? ZMUser)?.remoteIdentifier == first.remoteIdentifier
        }
    }
    
    var participants = [UserType]() {
        didSet { participantsDidChange?() }
    }

    init(participants: [UserType], selectedParticipants: [UserType], conversation: ZMConversation) {
        internalParticipants = participants
        self.conversation = conversation
        self.selectedParticipants = selectedParticipants.sorted { $0.displayName < $1.displayName }
        
        super.init()
        token = ConversationChangeInfo.add(observer: self, for: conversation)
        computeVisibleParticipants()
    }
    
    func isUserSelected(_ user: UserType) -> Bool {
        guard let id = (user as? ZMUser)?.remoteIdentifier else { return false }
        return selectedParticipants.contains { ($0 as? ZMUser)?.remoteIdentifier == id}
    }
    
    func computeVisibleParticipants() {
        guard var query = filterQuery?.lowercased(), query.isValidQuery else { return participants = internalParticipants }
        if query.hasPrefix("@") {
            query = String(query.dropFirst())
        }
        let filtered = internalParticipants.filter { item in
            (item.name?.lowercased().contains(query) ?? false) ||
                (item.handle?.lowercased().contains(query) ?? false)
        }
        participants = filtered
    }
    
    func conversationDidChange(_ changeInfo: ConversationChangeInfo) {
        guard changeInfo.participantsChanged else { return }
        internalParticipants = conversation.sortedOtherParticipants
        computeVisibleParticipants()
    }
    
    // MARK: - SearchHeaderViewControllerDelegate
    
    func searchHeaderViewController(
        _ searchHeaderViewController: SearchHeaderViewController,
        updatedSearchQuery query: String
        ) {
        filterQuery = query
        computeVisibleParticipants()
    }
    
    func searchHeaderViewControllerDidConfirmAction(_ searchHeaderViewController: SearchHeaderViewController) {
        // no-op
    }
    
}
