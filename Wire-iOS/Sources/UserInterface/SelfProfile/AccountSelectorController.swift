
import Foundation
import UIKit
import Cartography

final class AccountSelectorController: UIViewController {
    private var accountsView = AccountSelectorView()
    private var applicationDidBecomeActiveToken: NSObjectProtocol!

    init() {
        super.init(nibName: nil, bundle: nil)

        applicationDidBecomeActiveToken = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: { [weak self] _ in
            guard let `self` = self else {
                return
            }
            self.updateShowAccountsIfNeeded()
        })
        
        accountsView.delegate = self
        self.view.addSubview(accountsView)
        constrain(self.view, accountsView) { selfView, accountsView in
            accountsView.edges == selfView.edges
        }
        
        setShowAccounts(to: SessionManager.shared?.accountManager.accounts.count > 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var showAccounts: Bool = false
    
    internal func updateShowAccountsIfNeeded() {
        let showAccounts = SessionManager.shared?.accountManager.accounts.count > 1
        guard showAccounts != self.showAccounts else { return }
        setShowAccounts(to: showAccounts)
    }
    
    private func setShowAccounts(to showAccounts: Bool) {
        self.showAccounts = showAccounts
        accountsView.isHidden = !showAccounts
        self.view.frame.size = accountsView.frame.size
    }
}

extension AccountSelectorController: AccountSelectorViewDelegate {
    
    func accountSelectorDidSelect(account: Account) {
        guard account != SessionManager.shared?.accountManager.selectedAccount else { return }
        
        if ZClientViewController.shared?.conversationListViewController.presentedViewController != nil {
            AppDelegate.shared.rootViewController.confirmSwitchingAccount { (confirmed) in
                if confirmed {
                    ZClientViewController.shared?.conversationListViewController.dismiss(animated: true, completion: {
                        AppDelegate.shared.mediaPlaybackManager?.stop()
                        SessionManager.shared?.select(account)
                    })
                }
            }
        }
        else {
            SessionManager.shared?.select(account)
        }
    }
    
}

