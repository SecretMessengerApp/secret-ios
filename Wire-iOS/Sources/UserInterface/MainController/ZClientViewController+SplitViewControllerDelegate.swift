

import Foundation

extension ZClientViewController: SplitViewControllerDelegate {
    
    func splitViewControllerShouldMoveLeftViewController(_ splitViewController: SplitViewController) -> Bool {
        return splitViewController.rightViewController != nil &&
//            splitViewController.leftViewController == backgroundViewController &&
            conversationListViewController.state == .conversationList &&
            (conversationListViewController.presentedViewController == nil || splitViewController.isLeftViewControllerRevealed == false)

    }
}
