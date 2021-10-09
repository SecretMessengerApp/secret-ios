

import Foundation

extension ConversationListViewController.ViewModel: ConversationListContentDelegate {
    func conversationList(_ controller: ConversationListContentController?, didSelect conversation: ZMConversation?, focusOnView focus: Bool) {
        selectedConversation = conversation
    }
    
    func conversationListDidSelectNotDisturbed(_ controller: ConversationListContentController?) {
        self.viewController?.didSelectNoDisturbedConversations()
    }

    func conversationList(_ controller: ConversationListContentController?, willSelectIndexPathAfterSelectionDeleted conv: IndexPath?) {
        ZClientViewController.shared?.transitionToList(animated: true, completion: nil)
    }

    func conversationListDidScroll(_ controller: ConversationListContentController?) {
        guard let controller = controller else { return }
        viewController?.updateBottomBarSeparatorVisibility(with: controller)

        viewController?.scrollViewDidScroll(scrollView: controller.collectionView)
    }

    func conversationListContentController(_ controller: ConversationListContentController?, wantsActionMenuFor conversation: ZMConversation?, fromSourceView sourceView: UIView?) {
        showActionMenu(for: conversation, from: sourceView)
    }
}

extension ConversationListViewController.ViewModel {
    func showActionMenu(for conversation: ZMConversation!, from view: UIView!) {
        guard let viewController = viewController as? UIViewController else { return }

        actionsController = ConversationActionController(conversation: conversation, target: viewController)
        actionsController?.presentMenu(from: view, context: .list)
    }
}
