
import Foundation
import UIKit
import WireSystem

final class StartUIView : UIView { }

extension StartUIViewController {
    
    private func presentProfileViewController(for bareUser: UserType,
                                              at indexPath: IndexPath?) {
        searchHeaderViewController.tokenField.resignFirstResponder()

        guard
            let indexPath = indexPath,
            let cell = searchResultsViewController.searchResultsView?.collectionView.cellForItem(at: indexPath)
            else { return }

        profilePresenter.presentProfileViewController(for: bareUser, in: self, from: view.convert(cell.bounds, from: cell), onDismiss: {
            if self.isIPadRegular(),
                let indexPaths = self.searchResultsViewController.searchResultsView?.collectionView.indexPathsForVisibleItems {
                self.searchResultsViewController.searchResultsView?.collectionView.reloadItems(at: indexPaths)
            } else if self.profilePresenter.keyboardPersistedAfterOpeningProfile {
                    self.searchHeaderViewController.tokenField.becomeFirstResponder()
                    self.profilePresenter.keyboardPersistedAfterOpeningProfile = false
            }
        })
    }
}

extension StartUIViewController: SearchResultsViewControllerDelegate {

    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController,
                                            didTapOnUser user: UserType,
                                            indexPath: IndexPath,
                                            section: SearchResultsViewControllerSection) {
        
        if !user.isConnected && !user.isTeamMember {
            presentProfileViewController(for: user, at: indexPath)
        } else {
            delegate?.startUI(self, didSelect: user)
        }
    }
    
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController,
                                            didDoubleTapOnUser user: UserType,
                                            indexPath: IndexPath) {
    
        guard user.isConnected, !user.isBlocked else {
            return
        }
        
        delegate?.startUI(self, didSelect: user)
    }
    
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController,
                                            didTapOnConversation conversation: ZMConversation) {
        if [.group, .hugeGroup, .oneOnOne].contains(conversation.conversationType) {
            self.delegate?.startUI(self, didSelect: conversation)
        }
    }
    
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController,
                                            didTapOnSeviceUser user: ServiceUser) {

        let detail = ServiceDetailViewController(serviceUser: user,
                                                 actionType: .openConversation,
                                                 variant: ServiceDetailVariant(colorScheme: .dark, opaque: false)) { [weak self] result in
            guard let weakSelf = self else { return }

            if let result = result {
                switch result {
                case .success(let conversation):
                    weakSelf.delegate?.startUI(weakSelf, didSelect: conversation)
                case .failure(let error):
                    error.displayAddBotError(in: weakSelf)
                }
            } else {
                weakSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        
        navigationController?.pushViewController(detail, animated: true)
    }
    
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController, wantsToPerformAction action: SearchResultsViewControllerAction) {
        switch action {
        case .addFriend:
            openAddFriendController()
        case .createGroup:
            openCreateGroupController()
        case .createGuestRoom:
            createGuestRoom()
//        case .createHugeGroup:
//            openCreateHugeGroupController()
        case .inviteAddressbook:
            inviteAddressbookFriend()
        }
    }
    
    func openAddFriendController() {
        let controller = AddFriendViewController()
        if self.traitCollection.horizontalSizeClass == .compact {
            let avoiding = KeyboardAvoidingViewController(viewController: controller)
            self.navigationController?.pushViewController(avoiding, animated: true) {
                UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(true)
            }
        }
        else {
            let embeddedNavigationController = controller.wrapInNavigationController()
            embeddedNavigationController.modalPresentationStyle = .formSheet
            self.present(embeddedNavigationController, animated: true)
        }
    }
    
    func openCreateGroupController() {
        let controller = ConversationCreationController()
        controller.delegate = self
        
        if self.traitCollection.horizontalSizeClass == .compact {
            let avoiding = KeyboardAvoidingViewController(viewController: controller)
            self.navigationController?.pushViewController(avoiding, animated: true) {
            }
        }
        else {
            let embeddedNavigationController = controller.wrapInNavigationController()
            embeddedNavigationController.modalPresentationStyle = .formSheet
            self.present(embeddedNavigationController, animated: true)
        }
    }
    
    func openCreateHugeGroupController() {
        let controller = ConversationCreationController()
        controller.delegate = self
        controller.convType = .hugeGroup

        if self.traitCollection.horizontalSizeClass == .compact {
            let avoiding = KeyboardAvoidingViewController(viewController: controller)
            self.navigationController?.pushViewController(avoiding, animated: true) {
                UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(true)
            }
        }
        else {
            let embeddedNavigationController = controller.wrapInNavigationController()
            embeddedNavigationController.modalPresentationStyle = .formSheet
            self.present(embeddedNavigationController, animated: true)
        }
    }
    
    func inviteAddressbookFriend() {
        let inviteContactVC = ContactsViewController()
        self.wr_splitViewController?.pushToRightPossible(inviteContactVC, from: self)
//        if self.traitCollection.horizontalSizeClass == .compact {
//            self.navigationController?.pushViewController(inviteContactVC, animated: true)
//        }
//        else {
//            let embeddedNavigationController = inviteContactVC.wrapInNavigationController()
//            embeddedNavigationController.modalPresentationStyle = .formSheet
//            self.present(embeddedNavigationController, animated: true)
//        }
    }
    
    func createGuestRoom() {
        guard let userSession = ZMUserSession.shared() else {
            fatal("No user session present")
        }
        
        GuestRoomEvent.created.track()
        showLoadingView = true
        
        userSession.performChanges { [weak self] in
            guard let weakSelf = self else { return }
            
            if let conversation = ZMConversation.insertGroupConversation(into: userSession.managedObjectContext, withParticipants: [], name: "general.guest-room-name".localized, in: ZMUser.selfUser().team) {
                weakSelf.delegate?.startUI(weakSelf, didSelect: conversation)
            }
        }
    }
}

extension StartUIViewController: ConversationCreationControllerDelegate {
    
    func conversationCreationController(_ controller: ConversationCreationController, didSelectName name: String, participants: Set<ZMUser>, allowGuests: Bool) {
        
        dismiss(controller: controller) { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.delegate?.startUI(
                weakSelf,
                createConversationWith: UserSet(Array(participants)),
                name: name,
                allowGuests: allowGuests,
                enableReceipts: false
            )
        }
    }
    
    private func dismiss(controller: ConversationCreationController, completion: (() -> Void)? = nil) {
        if traitCollection.horizontalSizeClass == .compact {
            navigationController?.popToRootViewController(animated: true) {
                completion?()
            }
        } else {
            controller.navigationController?.dismiss(animated: true, completion: completion)
        }
    }
}

extension StartUIViewController: EmptySearchResultsViewDelegate {
    func execute(action: EmptySearchResultsViewAction, from: EmptySearchResultsView) {
        switch action {
        case .openManageServices:
            URL.manageTeam(source: .onboarding).openInApp(above: self)
        }
    }
}
