
import Foundation


extension ZClientViewController: ShowContentDelegate {
    private func wrapInNavigationControllerAndPresent(viewController: UIViewController) {
        let navWrapperController: UINavigationController = viewController.wrapInNavigationController()
        navWrapperController.modalPresentationStyle = .formSheet

        dismissAllModalControllers(callback: { [weak self] in
            self?.present(navWrapperController, animated: true)
        })
    }

    public func showConnectionRequest(userId: UUID) {
        let searchUserViewConroller = SearchUserViewConroller(userId: userId, profileViewControllerDelegate: self)

        wrapInNavigationControllerAndPresent(viewController: searchUserViewConroller)
    }

    public func showUserProfile(user: UserType) {
        let profileViewController = ProfileViewController(user: user, viewer: ZMUser.selfUser(), context: .profileViewer)
        profileViewController.delegate = self

        wrapInNavigationControllerAndPresent(viewController: profileViewController)
    }

    
    public func showConversation(_ conversation: ZMConversation, at message: ZMConversationMessage?) {
        switch conversation.conversationType {
        case .connection:
            selectIncomingContactRequestsAndFocus(onView: true)
        case .group, .oneOnOne, .hugeGroup:
            select(conversation: conversation,
                   scrollTo: message,
                   focusOnView: true,
                   animated: true,
                   completion: nil)
        default:
            break
        }
    }
    
    public func showConversationList() {
        transitionToList(animated: true, completion: nil)
    }
}
