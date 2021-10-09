
import Foundation

enum SearchGroup: Int {
    case people
    case services
}

extension SearchGroup {
    
    var accessible: Bool {
        switch self {
        case .people:
            return true
        case .services:
            return ZMUser.selfUser().canCreateService
        }
    }

#if ADD_SERVICE_DISABLED
    // remove service from the tab
    static let all: [SearchGroup] = [.people]
#else
    static var all: [SearchGroup] {
        return [.people, .services].filter { $0.accessible }
    }
#endif

    var name: String {
        switch self {
        case .people:
            return "peoplepicker.header.people".localized
        case .services:
            return "peoplepicker.header.services".localized
        }
    }
}

@objc
protocol SearchResultsViewControllerDelegate {
    
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController, didTapOnUser user: UserType, indexPath: IndexPath, section: SearchResultsViewControllerSection)
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController, didDoubleTapOnUser user: UserType, indexPath: IndexPath)
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController, didTapOnConversation conversation: ZMConversation)
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController, didTapOnSeviceUser user: ServiceUser)
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController, wantsToPerformAction action: SearchResultsViewControllerAction)
}

@objc
enum SearchResultsViewControllerAction : Int {
    case addFriend
    case createGroup
    case createGuestRoom
//    case createHugeGroup
    case inviteAddressbook
}

@objc
enum SearchResultsViewControllerMode : Int {
    case search
    case selection
    case list
}

@objc
enum SearchResultsViewControllerSection : Int {
    case unknown
    case topPeople
    case contacts
    case teamMembers
    case conversations
    case directory
    case services
}

@objc
enum SearchResultsViewControllerParticipantsWay:Int {
    case `default`
    case add
    case sub
    case share
    case changeCreator
    case select
}

extension UIViewController {
    class ControllerHierarchyIterator: IteratorProtocol {
        private var current: UIViewController

        init(controller: UIViewController) {
            current = controller
        }

        func next() -> UIViewController? {
            var candidate: UIViewController? = .none
            if let controller = current.navigationController {
                candidate = controller
            }
            else if let controller = current.presentingViewController {
                candidate = controller
            }
            else if let controller = current.parent {
                candidate = controller
            }
            if let candidate = candidate {
                current = candidate
            }
            return candidate
        }
    }

    func isContainedInPopover() -> Bool {
        var hierarchy = ControllerHierarchyIterator(controller: self)

        return hierarchy.any {
            if let arrowDirection = $0.popoverPresentationController?.arrowDirection,
                arrowDirection != .unknown {
                return true
            }
            else {
                return false
            }
        }
    }
}

final class SearchResultsViewController : UIViewController {

    var searchResultsView: SearchResultsView?
    var searchDirectory: SearchDirectory!
    let userSelection: UserSelection

    let sectionController: SectionCollectionViewController
    let contactsSection: ContactsSectionController
    let directorySection = DirectorySectionController()
    let conversationsSection: GroupConversationsSectionController
    let topPeopleSection: TopPeopleSectionController
    let servicesSection: SearchServicesSectionController
    let inviteTeamMemberSection: InviteTeamMemberSection
    let createGroupSection = CreateGroupSection()

    var pendingSearchTask: SearchTask? = nil
    var isAddingParticipants: Bool
    var participantsWay: SearchResultsViewControllerParticipantsWay
    var searchGroup: SearchGroup = .people {
        didSet {
            updateVisibleSections()
        }
    }

    var filterConversation: ZMConversation? = nil
    let shouldIncludeGuests: Bool

    weak var delegate: SearchResultsViewControllerDelegate? = nil

    var mode: SearchResultsViewControllerMode = .search {
        didSet {
            updateVisibleSections()
        }
    }

    deinit {
        searchDirectory?.tearDown()
    }

    var context: AddParticipantsViewController.Context?
    
    @objc
    init(userSelection: UserSelection, isAddingParticipants: Bool = false, participantsWay: SearchResultsViewControllerParticipantsWay = SearchResultsViewControllerParticipantsWay.default, shouldIncludeGuests: Bool) {
        self.userSelection = userSelection
        self.isAddingParticipants = isAddingParticipants
        self.participantsWay = participantsWay
        self.mode = .list
        self.shouldIncludeGuests = shouldIncludeGuests

        let team = ZMUser.selfUser().team
        let teamName = team?.name

        sectionController = SectionCollectionViewController()
        contactsSection = ContactsSectionController()
        contactsSection.selection = userSelection
        contactsSection.title = team != nil ? "peoplepicker.header.contacts_personal".localized : "peoplepicker.header.contacts".localized
        contactsSection.participantsWay = participantsWay
        servicesSection = SearchServicesSectionController(canSelfUserManageTeam: ZMUser.selfUser().canManageTeam)
        conversationsSection = GroupConversationsSectionController()
        conversationsSection.title = team != nil ? "peoplepicker.header.team_conversations".localized(args: teamName ?? "") : "peoplepicker.header.conversations".localized
        if let session = ZMUserSession.shared() {
            searchDirectory = SearchDirectory(userSession: session)
            topPeopleSection = TopPeopleSectionController(topConversationsDirectory: session.topConversationsDirectory)
        } else {
            topPeopleSection = TopPeopleSectionController(topConversationsDirectory:nil)
        }
        inviteTeamMemberSection = InviteTeamMemberSection(team: team)

        super.init(nibName: nil, bundle: nil)

        contactsSection.delegate = self
        directorySection.delegate = self
        topPeopleSection.delegate = self
        conversationsSection.delegate = self
        servicesSection.delegate = self
        createGroupSection.delegate = self
        inviteTeamMemberSection.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        searchResultsView  = SearchResultsView()
        searchResultsView?.parentViewController = self
        view = searchResultsView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sectionController.collectionView?.reloadData()
        sectionController.collectionView?.collectionViewLayout.invalidateLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        sectionController.collectionView = searchResultsView?.collectionView
        if #available(iOS 11.0, *) {
            sectionController.collectionView?.contentInsetAdjustmentBehavior = .always
        } else {
            // Fallback on earlier versions
        }
        updateVisibleSections()

        searchResultsView?.emptyResultContainer.isHidden = !isResultEmpty
    }

    @objc
    func cancelPreviousSearch() {
        pendingSearchTask?.cancel()
        pendingSearchTask = nil
    }

    private func performSearch(query: String, options: SearchOptions) {

        pendingSearchTask?.cancel()
        searchResultsView?.emptyResultContainer.isHidden = true

        let request = SearchRequest(query: query, searchOptions: options)
        if let task = searchDirectory?.perform(request) {
            task.onResult {
                [weak self] in
                self?.handleSearchResult(result: $0, isCompleted: $1)
            }
            task.start()

            pendingSearchTask = task
        }
    }

    @objc
    func searchForUsers(withQuery query: String) {
        self.performSearch(query: query, options: [.conversations, .contacts])
    }

    @objc
    func searchForLocalUsers(withQuery query: String) {
        self.performSearch(query: query, options: [.contacts, .teamMembers])
    }

    @objc
    func searchForServices(withQuery query: String) {
        self.performSearch(query: query, options: [.services])
    }
    

    @objc
    func searchForContractAndConversation(withQuery query: String) {
        self.performSearch(query: query, options: [.contacts, .conversations])
    }

    @objc
    func searchContactList() {
        searchForLocalUsers(withQuery: "")
    }

    var isResultEmpty: Bool = true {
        didSet {
            searchResultsView?.emptyResultContainer.isHidden = !isResultEmpty
        }
    }

    func handleSearchResult(result: SearchResult, isCompleted: Bool) {
        self.updateSections(withSearchResult: result)

        if isCompleted {
            isResultEmpty = sectionController.visibleSections.isEmpty
        }
    }

    func updateVisibleSections() {
        var sections : [CollectionViewSectionController]

        switch(self.searchGroup, participantsWay) {
        case (.services, _):
            sections = [servicesSection]
        case (.people, .default):
            switch mode {
            case .search:
                sections = [contactsSection, conversationsSection, directorySection]
            case .selection:
                sections = [contactsSection]
            case .list:
                sections = [createGroupSection, topPeopleSection, contactsSection]
            }
        case (.people, .add):
            switch mode {
            case .search:
                sections = [contactsSection]
            case .selection:
                sections = [contactsSection]
            case .list:
                sections = [contactsSection]
            }
        case (.people, .sub):
            switch mode {
            case .search:
                sections = [contactsSection]
            case .selection:
                sections = [contactsSection]
            case .list:
                sections = [contactsSection]
            }
        case (.people, .share):
            switch mode {
            case .search:
                sections = [contactsSection]
            case .selection:
                sections = [contactsSection]
            case .list:
                sections = [contactsSection]
            }
        case (.people, .changeCreator):
            switch mode {
            case .search:
                sections = [contactsSection]
            case .selection:
                sections = [contactsSection]
            case .list:
                sections = [contactsSection]
            }
      case (.people, .select):
            sections = [contactsSection]
        }

        sectionController.sections = sections
    }

    func updateSections(withSearchResult searchResult: SearchResult) {

        var contacts = searchResult.contacts

        if let filteredParticpants = filterConversation?.activeParticipants {
            if self.participantsWay == .default || self.participantsWay == .add {
                contacts = contacts.filter({ !filteredParticpants.contains($0) })
            } else if self.participantsWay == .changeCreator {
                contacts = contacts.filter({ filteredParticpants.contains($0) })
            }
        }
        
        if context != nil {
           contactsSection.contacts = contacts
        }

        directorySection.suggestions = searchResult.directory
        conversationsSection.groupConversations = searchResult.conversations
        servicesSection.services = searchResult.services

        sectionController.collectionView?.reloadData()
    }

    func sectionFor(controller: CollectionViewSectionController) -> SearchResultsViewControllerSection {
        if controller === topPeopleSection {
            return .topPeople
        } else if controller === contactsSection {
            return .contacts
        } else if  controller === conversationsSection {
            return .conversations
        } else if controller === directorySection {
            return .directory
        } else if controller === servicesSection {
            return .services
        } else {
            return .unknown
        }
    }

}

extension SearchResultsViewController : SearchSectionControllerDelegate {

    func searchSectionController(_ searchSectionController: CollectionViewSectionController, didSelectUser user: UserType, at indexPath: IndexPath) {
        if let user = user as? ZMUser {
            delegate?.searchResultsViewController(self, didTapOnUser: user, indexPath: indexPath, section: sectionFor(controller: searchSectionController))
        }
        else if let service = user as? ServiceUser, service.isServiceUser {
            delegate?.searchResultsViewController(self, didTapOnSeviceUser: service)
        }
        else if let searchUser = user as? ZMSearchUser {
            delegate?.searchResultsViewController(self, didTapOnUser: searchUser, indexPath: indexPath, section: sectionFor(controller: searchSectionController))
        }
    }

    func searchSectionController(_ searchSectionController: CollectionViewSectionController, didSelectConversation conversation: ZMConversation, at indexPath: IndexPath) {
        delegate?.searchResultsViewController(self, didTapOnConversation: conversation)
    }

    func searchSectionController(_ searchSectionController: CollectionViewSectionController, didSelectRow row: CreateGroupSection.Row, at indexPath: IndexPath) {
        switch row {
        case .addFriend:
            delegate?.searchResultsViewController(self, wantsToPerformAction: .addFriend)
        case .createGroup:
            delegate?.searchResultsViewController(self, wantsToPerformAction: .createGroup)
        case .createGuestRoom:
            delegate?.searchResultsViewController(self, wantsToPerformAction: .createGuestRoom)
//        case .createHugeGroup:
//            delegate?.searchResultsViewController(self, wantsToPerformAction: .createHugeGroup)
        case .inviteAddressbook:
            delegate?.searchResultsViewController(self, wantsToPerformAction: .inviteAddressbook)
        }

    }

}

extension SearchResultsViewController : InviteTeamMemberSectionDelegate {
    func inviteSectionDidRequestTeamManagement() {
        URL.manageTeam(source: .onboarding).openInApp(above: self)
    }
}

extension SearchResultsViewController : SearchServicesSectionDelegate {
    func addServicesSectionDidRequestOpenServicesAdmin() {
        URL.manageTeam(source: .settings).openInApp(above: self)
    }
}
