
import UIKit

private let zmLog = ZMSLog(tag: "StartUIViewController")

final class StartUIViewController: UIViewController {
    
    static let InitiallyShowsKeyboardConversationThreshold = 10
    
    weak var delegate: StartUIDelegate?
    
    let searchHeaderViewController: SearchHeaderViewController = SearchHeaderViewController(userSelection: UserSelection())
    
    let groupSelector: SearchGroupSelector = SearchGroupSelector(style: .dark)
    
    let searchResultsViewController: SearchResultsViewController = {
        let viewController = SearchResultsViewController(userSelection: UserSelection(), isAddingParticipants: false, shouldIncludeGuests: true)
        viewController.mode = .list
        
        return viewController
    }()
    
    var addressBookUploadLogicHandled = false
    
    var addressBookHelperType: AddressBookHelperProtocol.Type
    
    var addressBookHelper: AddressBookHelperProtocol {
        AddressBookHelper.sharedHelper
    }
    
    let quickActionsBar: StartUIInviteActionBar = StartUIInviteActionBar()
    
    let profilePresenter: ProfilePresenter = ProfilePresenter()
    private var emptyResultView: EmptySearchResultsView!
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// init method for injecting mock addressBookHelper
    ///
    /// - Parameter addressBookHelperType: a class type conforms AddressBookHelperProtocol
    init(addressBookHelperType: AddressBookHelperProtocol.Type = AddressBookHelper.self) {
        self.addressBookHelperType = addressBookHelperType
        
        super.init(nibName: nil, bundle: nil)
        
        configGroupSelector()
        setupViews()
    }
    
    var searchHeader: SearchHeaderViewController {
        return self.searchHeaderViewController
    }

    var searchResults: SearchResultsViewController {
        return self.searchResultsViewController
    }

    var selfUser: UserType {
        return SelfUser.current
    }
    
    // MARK: - Overloaded methods
    override func loadView() {
        view = StartUIView(frame: CGRect.zero)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        endEditing()
    }
    
    private func configGroupSelector() {
        groupSelector.translatesAutoresizingMaskIntoConstraints = false
        groupSelector.backgroundColor = UIColor.from(scheme: .searchBarBackground, variant: .dark)
    }

    func setupViews() {
        configGroupSelector()
        emptyResultView = EmptySearchResultsView(variant: .light, isSelfUserAdmin: selfUser.canManageTeam)

        emptyResultView.delegate = self
        
        searchResultsViewController.mode = .list
        searchResultsViewController.searchResultsView?.emptyResultView = self.emptyResultView
        searchResultsViewController.searchResultsView?.collectionView.accessibilityIdentifier = "search.list"
        
        title = "peoplepicker.title".localized
        
        searchHeader.delegate = self
        searchHeader.allowsMultipleSelection = false
        searchHeader.view.backgroundColor = UIColor.from(scheme: .searchBarBackground, variant: .dark)
        
        addToSelf(searchHeader)
        
        groupSelector.onGroupSelected = { [weak self] group in
            if .services == group {
                // Remove selected users when switching to services tab to avoid the user confusion: users in the field are
                // not going to be added to the new conversation with the bot.
                self?.searchHeader.clearInput()
            }
            
            self?.searchResults.searchGroup = group
            self?.performSearch()
        }
        
        if showsGroupSelector {
            view.addSubview(groupSelector)
        }
        
        searchResults.delegate = self
        addToSelf(searchResults)
        searchResults.searchResultsView?.emptyResultView = emptyResultView
        searchResults.searchResultsView?.collectionView.accessibilityIdentifier = "search.list"
        
//        quickActionsBar.inviteButton.addTarget(self, action: #selector(inviteMoreButtonTapped(_:)), for: .touchUpInside)
                
        createConstraints()
//        updateActionBar()
        searchResults.searchContactList()
        
        view.accessibilityViewIsModal = true
    }

    func showKeyboardIfNeeded() {
        let conversationCount = ZMConversationList.conversations(inUserSession: ZMUserSession.shared()!).count ///TODO: unwrap
        if conversationCount > StartUIViewController.InitiallyShowsKeyboardConversationThreshold {
            _ = searchHeader.tokenField.becomeFirstResponder()
        }
        
    }
    
//    func updateActionBar() {
//        if !searchHeader.query.isEmpty || (selfUser as? ZMUser)?.hasTeam == true {
//            searchResults.searchResultsView?.accessoryView = nil
//        } else {
//            searchResults.searchResultsView?.accessoryView = quickActionsBar
//        }
//
//        view.setNeedsLayout()
//    }
    
    private func onDismissPressed() {
        _ = searchHeader.tokenField.resignFirstResponder()
        navigationController?.dismiss(animated: true)
    }
    
    override func accessibilityPerformEscape() -> Bool {
        onDismissPressed()
        return true
    }

    // MARK: - Instance methods
    @objc private func performSearch() {
        let searchString = searchHeader.query
        zmLog.info("Search for \(searchString)")
        
        if groupSelector.group == .people {
            if searchString.count == 0 {
                searchResults.mode = .list
                searchResults.searchContactList()
            } else {
                searchResults.mode = .search
                searchResults.searchForUsers(withQuery: searchString)
            }
        } else {
            searchResults.searchForServices(withQuery: searchString)
        }
        emptyResultView.updateStatus(searchingForServices: groupSelector.group == .services,
                                     hasFilter: !searchString.isEmpty)
    }
    
    // MARK: - Action bar

//    @objc
//    func inviteMoreButtonTapped(_ sender: UIButton?) {
//        if needsAddressBookPermission {
//            presentShareContactsViewController()
//        } else {
//            navigationController?.pushViewController(ContactsViewController(), animated: true)
//        }
//    }

}

extension StartUIViewController: SearchHeaderViewControllerDelegate {
    func searchHeaderViewController(_ searchHeaderViewController : SearchHeaderViewController, updatedSearchQuery query: String) {
        searchResults.cancelPreviousSearch()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        perform(#selector(performSearch), with: nil, afterDelay: 0.2)
    }
    
    func searchHeaderViewControllerDidConfirmAction(_ searchHeaderViewController : SearchHeaderViewController) {
        searchHeaderViewController.resetQuery()
    }
}
