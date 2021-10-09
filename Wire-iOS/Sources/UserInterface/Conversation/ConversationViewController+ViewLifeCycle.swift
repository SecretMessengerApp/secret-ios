

import Foundation

extension ConversationViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateLeftNavigationBarItems()

        if isFocused {
            // We are presenting the conversation screen so mark it as the last viewed screen,
            // but only if we are acutally focused (otherwise we would be shown on the next launch)
            Settings.shared[.lastViewedScreen] = SettingsLastScreen.conversation
            if let currentAccount = SessionManager.shared?.accountManager.selectedAccount {
                Settings.shared.setLastViewed(conversation: conversation, for: currentAccount)
            }
        }


        contentViewController.searchQueries = collectionController?.currentTextSearchQuery ?? []

        ZMUserSession.shared()?.didOpen(conversation: conversation)

        isAppearing = false
    }
}
