

import Foundation

protocol ArchivedListViewModelDelegate: class {
    func archivedListViewModel(_ model: ArchivedListViewModel, didUpdateArchivedConversationsWithChange change: ConversationListChangeInfo, applyChangesClosure: @escaping ()->())
    func archivedListViewModel(_ model: ArchivedListViewModel, didUpdateConversationWithChange change: ConversationChangeInfo)
}

 final class ArchivedListViewModel: NSObject {

    weak var delegate: ArchivedListViewModelDelegate?
    var archivedConversationListObserverToken: NSObjectProtocol?
    var archivedConversations = [ZMConversation]()
    
    override init() {
        super.init()
        if let userSession = ZMUserSession.shared() {
            let list = ZMConversationList.archivedConversations(inUserSession: userSession)
            archivedConversationListObserverToken = ConversationListChangeInfo.add(observer: self, for: list, userSession: userSession)
            archivedConversations = list.asArray() as! [ZMConversation]
        }
    }
    
    var count: Int {
        return archivedConversations.count
    }
    
    subscript(key: Int) -> ZMConversation? {
        return archivedConversations[key]
    }
    
}


extension ArchivedListViewModel: ZMConversationListObserver {
    func conversationListDidChange(_ changeInfo: ConversationListChangeInfo) {
        guard changeInfo.conversationList == ZMConversationList.archivedConversations(inUserSession: ZMUserSession.shared()!) else { return }
        delegate?.archivedListViewModel(self, didUpdateArchivedConversationsWithChange: changeInfo) { [weak self] in
            self?.archivedConversations = ZMConversationList.archivedConversations(inUserSession: ZMUserSession.shared()!).asArray() as! [ZMConversation]
        }
    }
    
    func conversationInsideList(_ list: ZMConversationList, didChange changeInfo: ConversationChangeInfo) {
        delegate?.archivedListViewModel(self, didUpdateConversationWithChange: changeInfo)
    }
}
