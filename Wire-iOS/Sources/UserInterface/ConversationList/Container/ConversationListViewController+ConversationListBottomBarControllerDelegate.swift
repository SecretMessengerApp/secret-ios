

import Foundation

extension ConversationListViewController: ConversationListBottomBarControllerDelegate {

    func conversationListBottomBar(_ bar: ConversationListBottomBarController, didTapButtonWithType buttonType: ConversationListButtonType) {
        switch buttonType {
        case .archive:
            setState(.archived, animated: true)
        case .startUI:
            presentPeoplePicker()
        case .folder:
            listContentController.listViewModel.folderEnabled = true
        case .list:
            listContentController.listViewModel.folderEnabled = false
        }
    }
}
