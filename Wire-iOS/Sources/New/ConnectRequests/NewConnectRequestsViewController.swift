

import UIKit

class NewConnectRequestsViewController: UITableViewController {

    var connectionRequests: [ZMConversation]?
    
    var pendingConnectionsListObserverToken: NSObjectProtocol?
    
    var userObserverToken: Any?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "connection_request_pending_title".localized
    
        let pendingConnectionsList = ZMConversationList.pendingConnectionConversations(inUserSession: ZMUserSession.shared()!)
        
        if let session = ZMUserSession.shared() {
            pendingConnectionsListObserverToken = ConversationListChangeInfo.add(observer: self, for: pendingConnectionsList, userSession: session)
            userObserverToken = UserChangeInfo.add(observer: self, for: ZMUser.selfUser(), userSession: session)
        }
        
        connectionRequests = pendingConnectionsList as? [ZMConversation]
        
        reload()
        
        tableView.registerCell(IncomingConnectionTableViewCell.self)
        tableView.backgroundColor = .dynamic(scheme: .background)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .dynamic(scheme: .separator)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.estimatedSectionFooterHeight = 0.0
        
        let button = AuthenticationNavigationBar.makeBackButton()
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    

    fileprivate func reload() {
        tableView.reloadData()
        if let connectionRequests = connectionRequests,
            connectionRequests.count == 0 {
            ZClientViewController.shared?.hideIncomingContactRequests(completion: nil)
        }
    }
    
    @objc private func backButtonTapped() {
        let revealed = self.wr_splitViewController?.isLeftViewControllerRevealed ?? false
        self.wr_splitViewController?.setLeftViewControllerRevealed(!revealed, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectionRequests?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(IncomingConnectionTableViewCell.self, for: indexPath)
        if let connectionRequests = connectionRequests {
            let conversation = connectionRequests[connectionRequests.count - 1 - indexPath.row]
            let user = conversation.connectedUser
            cell.user = user
            cell.acceptBlock = { [weak self] in
                if let connectionRequests = self?.connectionRequests,
                    connectionRequests.count == 0 {
                    ZClientViewController.shared?.hideIncomingContactRequests(completion: {
                        guard let conversation = user?.oneToOneConversation else { return }
                        ZClientViewController.shared?.select(conversation: conversation, focusOnView: true, animated: true)
                    })
                }
            }
            
            cell.ignoreBlock = {
                if connectionRequests.count == 0 {
                    ZClientViewController.shared?.hideIncomingContactRequests(completion: nil)
                }
            }
        }
        return cell
    }
}

extension NewConnectRequestsViewController: ZMConversationListObserver, ZMUserObserver {
    func userDidChange(_ changeInfo: UserChangeInfo) {
        self.tableView.reloadData()
    }
    
    func conversationListDidChange(_ changeInfo: ConversationListChangeInfo) {
        self.connectionRequests = changeInfo.conversationList as? [ZMConversation]
        self.reload()
    }
}
