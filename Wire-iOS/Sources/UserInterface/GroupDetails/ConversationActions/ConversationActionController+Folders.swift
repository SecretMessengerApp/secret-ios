
import UIKit

extension ConversationActionController {
    
    func openMoveToFolder(for conversation: ZMConversation) {
        guard let directory = ZMUserSession.shared()?.conversationDirectory else { return }
        let folderPicker = FolderPickerViewController(conversation: conversation, directory: directory)
        folderPicker.delegate = self
        self.present(folderPicker.wrapInNavigationController(navigationBarClass: DefaultNavigationBar.self))
    }
}

extension ConversationActionController: FolderPickerViewControllerDelegate {
    
    func didPickFolder(_ folder: LabelType, for conversation: ZMConversation) {
        guard let userSession = ZMUserSession.shared() else { return }
        
        userSession.enqueueChanges {
            conversation.moveToFolder(folder)
        }
    }
    
}
