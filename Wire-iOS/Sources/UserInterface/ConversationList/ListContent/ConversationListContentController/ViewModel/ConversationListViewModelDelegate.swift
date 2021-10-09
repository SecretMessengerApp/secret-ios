

import DifferenceKit
import WireDataModel

/// a item which can be presented in the conversaton list
protocol ConversationListItem: NSObject {}

extension ZMConversation: ConversationListItem {}

// Placeholder for conversation requests item
final class ConversationListConnectRequestsItem: NSObject, ConversationListItem {}

final class ConversationListTopConversationItem: NSObject, ConversationListItem {}

final class ConversationListNoDisturbConversationItem: NSObject, ConversationListItem {}

protocol ConversationListViewModelDelegate: class {
    func listViewModel(_ model: ConversationListViewModel?, didSelectItem item: ConversationListItem?)

    func listViewModelShouldBeReloaded()

    func listViewModel(_ model: ConversationListViewModel?, didUpdateSectionForReload section: Int, animated: Bool)
    
    func listViewModel(_ model: ConversationListViewModel?, didChangeFolderEnabled folderEnabled: Bool)

    func listViewModel(_ model: ConversationListViewModel?, didUpdateSection section: Int)

    @discardableResult
    func reload<C>(
    using stagedChangeset: StagedChangeset<C>,
    interrupt: ((Changeset<C>) -> Bool)?,
    setData: (C?) -> Void
    ) -> UICollectionView
}

protocol ConversationListViewModelRestorationDelegate: class {
    func listViewModel(_ model: ConversationListViewModel?, didRestoreFolderEnabled enabled: Bool)
}
