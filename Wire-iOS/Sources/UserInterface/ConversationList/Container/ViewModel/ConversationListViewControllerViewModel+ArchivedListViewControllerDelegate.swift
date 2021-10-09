

import Foundation

extension ConversationListViewController.ViewModel: ArchivedListViewControllerDelegate {
    func archivedListViewControllerWantsToDismiss(_ controller: ArchivedListViewController) {
        viewController?.setState(.conversationList, animated: true, completion: nil)
    }

    func archivedListViewController(_ controller: ArchivedListViewController,
                                    didSelectConversation conversation: ZMConversation) {
        viewController?.setState(.conversationList, animated: true, completion:{
            self.viewController?.selectOnListContentController(conversation, scrollTo: nil, focusOnView: true, animated: true, completion: nil)
        })
    }
}
