

import Foundation

extension ConversationListViewController.ViewModel: UserProfileUpdateObserver {

    func didFailToSetHandle() {
        viewController?.openChangeHandleViewController(with: "")
    }

    func didFailToSetHandleBecauseExisting() {
        viewController?.openChangeHandleViewController(with: "")
    }

    func didSetHandle() {
        removeUsernameTakeover()
    }

    func didFindHandleSuggestion(handle: String) {
        showUsernameTakeover(with: handle)
        if let userSession = ZMUserSession.shared(), let selfUser = ZMUser.selfUser() {
            selfUser.fetchMarketingConsent(in: userSession, completion: {[weak self] result in
                switch result {
                case .failure:
                    self?.viewController?.showNewsletterSubscriptionDialogIfNeeded(completionHandler: { marketingConsent in
                        selfUser.setMarketingConsent(to: marketingConsent, in: userSession, completion: { _ in })
                    })
                case .success:
                    // The user already gave a marketing consent, no need to ask for it again.
                    return
                }
            })
        }
    }

}

extension ConversationListViewController.ViewModel: ZMUserObserver {

    func userDidChange(_ note: UserChangeInfo) {
        if ZMUser.selfUser().handle != nil && note.handleChanged {
            removeUsernameTakeover()
        } else if note.teamsChanged {
            updateNoConversationVisibility()
        }
    }
}

extension ConversationListViewController.ViewModel: UserNameTakeOverViewControllerDelegate {

    func takeOverViewController(_ viewController: UserNameTakeOverViewController, didPerformAction action: UserNameTakeOverViewControllerAction) {

        perform(action)

        // show data usage dialog after user name take over screen
        ZClientViewController.shared?.showDataUsagePermissionDialogIfNeeded()
    }
}

/// Debug flag to ensure the takeover screen is shown even though
/// the selfUser already has a handle assigned.
private let debugOverrideShowTakeover = false

extension ConversationListViewController.ViewModel {

    private func perform(_ action: UserNameTakeOverViewControllerAction) {
        switch action {
        case .chooseOwn(let suggested): viewController?.openChangeHandleViewController(with: suggested)
        case .keepSuggestion(let suggested):
            setSuggested(handle: suggested)
        case .learnMore:
            if let viewController = viewController as? UIViewController {
                URL.wr_usernameLearnMore.openInApp(above: viewController)
            }
        }
    }

    func removeUsernameTakeover() {
        viewController?.removeUsernameTakeover()
        removeUserProfileObserver()
    }

    private func removeUserProfileObserver() {
        userProfileObserverToken = nil
    }

    func showUsernameTakeover(with handle: String) {
        guard let name = ZMUser.selfUser().name, nil == ZMUser.selfUser().handle || debugOverrideShowTakeover else { return }

        viewController?.showUsernameTakeover(suggestedHandle: handle, name: name)

        if ZClientViewController.shared?.traitCollection.userInterfaceIdiom == .pad {
            ZClientViewController.shared?.loadPlaceholderConversationController(animated: false)
        }
    }

}

