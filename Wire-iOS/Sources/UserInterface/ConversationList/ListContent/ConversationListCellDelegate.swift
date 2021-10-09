

import Foundation

protocol ConversationListCellDelegate: class {
    func conversationListCellOverscrolled(_ cell: ConversationListCell)
    func conversationListCellJoinCallButtonTapped(_ cell: ConversationListCell)

    func indexPath(for cell: ConversationListCell) -> IndexPath?
}
