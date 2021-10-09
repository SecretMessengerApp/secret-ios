
import Foundation

extension ConversationContentViewController {
    
    func scroll(to message: ZMConversationMessage?, completion: ((UIView) -> Void)? = nil) {
        if let message = message {

            if message.hasBeenDeleted {
                presentAlertWithOKButton(message: "conversation.alert.message_deleted".localized)
            } else {
                dataSource.loadMessages(near: message) { index in

                    guard message.conversation == self.conversation else {
                        fatal("Message from the wrong conversation")
                    }

                    guard let indexToShow = index else {
                        return
                    }

                    self.tableView.scrollToRow(at: indexToShow, at: .top, animated: false)

                    if let cell = self.tableView.cellForRow(at: indexToShow) {
                        completion?(cell)
                    }
                }
            }
        } else {
            dataSource.loadMessages()
        }
        
        updateTableViewHeaderView()
    }
    
    func scrollToBottom() {
        guard !isScrolledToBottom else { return }
        
        dataSource.loadMessages()
        tableView.scroll(toIndex: 0)
        
        updateTableViewHeaderView()
    }
    
    func scrollToBottomForInit() {
        
        dataSource.loadMessages()
        tableView.scroll(toIndex: 0)
        
        updateTableViewHeaderView()
    }
}
