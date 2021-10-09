
import UIKit

protocol AddFriendSearchResultsViewControllerDelegate: class {
    
    func addFriendSearchResultsViewController(_ viewController: AddFriendSearchResultsViewController, didTapOnUser user: UserType, indexPath: IndexPath, section: SearchResultsViewControllerSection)
    func addFriendSearchResultsViewController(_ viewController: AddFriendSearchResultsViewController, wantsToPerformAction action: AddFriendSearchResultsViewController.Action)
}

class AddFriendSearchResultsViewController: UIViewController {
    
    enum Action {
        case scan
        case phoneContacts
    }
    
    var searchResultsView: SearchResultsView?
    let userSelection: UserSelection
    
    private let sectionController: SectionCollectionViewController
    private let scanSection = AddFriendScanSection()
    private let directorySection = DirectorySectionController()
    private let contactsSection: ContactsSectionController
    
    private var pendingSearchTask: SearchTask? = nil
    private var participantsWay: SearchResultsViewControllerParticipantsWay
    private var searchDirectory: SearchDirectory!
    
    var searchGroup: SearchGroup = .people {
        didSet {
            updateVisibleSections()
        }
    }
    
    weak var delegate: AddFriendSearchResultsViewControllerDelegate? = nil
    
    public var mode: SearchResultsViewControllerMode = .list {
        didSet {
            updateVisibleSections()
        }
    }
    
    deinit {
        searchDirectory?.tearDown()
    }
    
    public init(userSelection: UserSelection) {
        self.userSelection = userSelection
        self.participantsWay = .default
        
        sectionController = SectionCollectionViewController()
        contactsSection = ContactsSectionController()
        contactsSection.selection = userSelection
        contactsSection.title = "peoplepicker.header.contacts".localized
        contactsSection.participantsWay = .default
        
        if let session = ZMUserSession.shared() {
            searchDirectory = SearchDirectory(userSession: session)
        }
        
        super.init(nibName: nil, bundle: nil)
        
        scanSection.delegate = self
        directorySection.delegate = self
        contactsSection.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        searchResultsView = SearchResultsView()
        searchResultsView?.parentViewController = self
        view = searchResultsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionController.collectionView = searchResultsView?.collectionView
        updateVisibleSections()
        searchResultsView?.emptyResultContainer.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sectionController.collectionView?.reloadData()
        sectionController.collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func cancelPreviousSearch() {
        pendingSearchTask?.cancel()
        pendingSearchTask = nil
    }
    
    func searchForLocalUsers(withQuery query: String) {
        performSearch(query: query, options: [.contacts, .directory])
    }
    
    private func performSearch(query: String, options: SearchOptions) {
        pendingSearchTask?.cancel()
        searchResultsView?.emptyResultContainer.isHidden = true
        
        var options = options
        options.updateForSelfUserTeamRole(selfUser: ZMUser.selfUser())
        
        let request = SearchRequest(query: query, searchOptions: options, team: ZMUser.selfUser().team)
        if let task = searchDirectory?.perform(request) {
            task.onResult({ [weak self] in self?.handleSearchResult(result: $0, isCompleted: $1)})
            task.start()
            pendingSearchTask = task
        }
    }
    
    private var isResultEmpty: Bool = true {
        didSet {
            searchResultsView?.emptyResultContainer.isHidden = !isResultEmpty
        }
    }
    
    private func handleSearchResult(result: SearchResult, isCompleted: Bool) {
        self.updateSections(withSearchResult: result)
        
        if isCompleted {
            isResultEmpty = sectionController.visibleSections.isEmpty
        }
    }
    
    private func updateVisibleSections() {
        var sections: [CollectionViewSectionController] = [scanSection]
        if  case (.people, .default) = (searchGroup, participantsWay),
            case .search = mode {
            sections = [contactsSection, directorySection]
        }
        sectionController.sections = sections
    }
    
    private func updateSections(withSearchResult searchResult: SearchResult) {
        contactsSection.contacts = searchResult.contacts
        directorySection.suggestions = searchResult.directory
        sectionController.collectionView?.reloadData()
    }
    
    private func sectionFor(controller: CollectionViewSectionController) -> SearchResultsViewControllerSection {
        if controller === contactsSection {
            return .contacts
        } else if controller === directorySection {
            return .directory
        } else {
            return .unknown
        }
    }
}


// MARK: - SearchSectionControllerDelegate
extension AddFriendSearchResultsViewController: SearchSectionControllerDelegate {
    
    func searchSectionController(_ searchSectionController: CollectionViewSectionController, didSelectUser user: UserType, at indexPath: IndexPath) {
        delegate?.addFriendSearchResultsViewController(self, didTapOnUser: user, indexPath: indexPath, section: sectionFor(controller: searchSectionController))
    }
    
    
    func searchSectionController(_ searchSectionController: CollectionViewSectionController, didSelectConversation conversation: ZMConversation, at indexPath: IndexPath) {
        // do nothing
    }
    
    func searchSectionController(_ searchSectionController: CollectionViewSectionController, didSelectRow row: CreateGroupSection.Row, at indexPath: IndexPath) {
        // do nothing
    }
}


extension AddFriendSearchResultsViewController: AddFriendScanSectionDelegate {
    
    func section(_ section: CollectionViewSectionController, didSelectRow row: AddFriendScanSection.Row, at indexPath: IndexPath) {
        switch row {
        case .scan:
            delegate?.addFriendSearchResultsViewController(self, wantsToPerformAction: .scan)
        case .phoneContacts:
            delegate?.addFriendSearchResultsViewController(self, wantsToPerformAction: .phoneContacts)
        }
    }   
}
