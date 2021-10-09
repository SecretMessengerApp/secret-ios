
import Foundation
import WireShareEngine


private let cellReuseIdentifier = "ConversationCell"


class ConversationSelectionViewController : UITableViewController {
    
    fileprivate let sharingSession: SharingSession
    
    fileprivate var allConversations : [Conversation]
    fileprivate var visibleConversations : [Conversation]

    var selectionHandler : ((_ conversation: Conversation) -> Void)?
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    init(conversations: [Conversation], sharingSession: SharingSession) {
        self.sharingSession = sharingSession
        
        allConversations = conversations
        visibleConversations = conversations
        
        super.init(style: .plain)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        tableView.register(TargetConversationCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal

        preferredContentSize = UIScreen.main.bounds.size
        definesPresentationContext = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        let searchBar = searchController.searchBar
        tableView.tableHeaderView = searchBar
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleConversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conversation = visibleConversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! TargetConversationCell
        cell.configure(for: conversation)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let selectionHandler = selectionHandler {
            selectionHandler(visibleConversations[indexPath.row])
        }
    }
}

extension ConversationSelectionViewController : UISearchResultsUpdating {
    internal func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            let searchConversation = sharingSession.searchSharedConversation(with: searchText)
            visibleConversations = searchConversation
        } else {
            visibleConversations = allConversations
        }
        tableView.reloadData()
    }
}
