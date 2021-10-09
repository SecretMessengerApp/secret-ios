
import UIKit

protocol AddFriendViewControllerDelegate: class {
    func addFriendViewControllerWantToDismissByTapX(_ controller: AddFriendViewController)
}

final class AddFriendViewController: UIViewController {

    private var searchHeaderViewController: SearchHeaderViewController!
    private var searchResultsViewController: AddFriendSearchResultsViewController!
    private var emptySearchResultsView: EmptySearchResultsView!
    private var groupSelector: SearchGroupSelector!
    private var profilePresenter = ProfilePresenter()
    private var navBarBackgroundView = UIView()
    weak var delegate: AddFriendViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "conversation_list.popover.add_friend".localized
        view.backgroundColor = .dynamic(scheme: .background)
        
        emptySearchResultsView = EmptySearchResultsView(variant: .light, isSelfUserAdmin: true)
        emptySearchResultsView.delegate = self

        searchHeaderViewController = SearchHeaderViewController(
            userSelection: UserSelection()
        )
        searchHeaderViewController.delegate = self
        searchHeaderViewController.allowsMultipleSelection = false
        addToSelf(searchHeaderViewController)
        
        groupSelector = SearchGroupSelector(style: .dark)
        groupSelector.translatesAutoresizingMaskIntoConstraints = false
        groupSelector.backgroundColor = UIColor.from(scheme: .searchBarBackground, variant: .dark)
        groupSelector.onGroupSelected = { [weak self] group in
            guard let self = self else { return }
            if group == .services {
                self.searchHeaderViewController.clearInput()
            }
            self.searchResultsViewController.searchGroup = group
            self.performSearch()
        }
        
        searchResultsViewController = AddFriendSearchResultsViewController(
            userSelection: UserSelection()
        )
        searchResultsViewController.searchResultsView?.emptyResultView = emptySearchResultsView
        searchResultsViewController.delegate = self
        addToSelf(searchResultsViewController)
        
        view.addSubview(navBarBackgroundView)
        
        setupNavigationBar()
        
        makeConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endEditing()
    }

    private func makeConstraints() {
        [navBarBackgroundView,
         searchHeaderViewController.view,
         groupSelector,
         searchResultsViewController.view
        ].forEach { $0?.translatesAutoresizingMaskIntoConstraints = false }
        let constraints: [NSLayoutConstraint] = showsGroupSelector
            ? [groupSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               groupSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               groupSelector.topAnchor.constraint(equalTo: searchHeaderViewController.view.bottomAnchor),
               searchResultsViewController.view.topAnchor.constraint(equalTo: groupSelector.bottomAnchor)]
            : [searchResultsViewController.view.topAnchor.constraint(equalTo: searchHeaderViewController.view.bottomAnchor)]
        
        NSLayoutConstraint.activate(
            [
                navBarBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navBarBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
                navBarBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                navBarBackgroundView.bottomAnchor.constraint(equalTo: view.safeTopAnchor),
                
                searchHeaderViewController.view.topAnchor.constraint(equalTo: navBarBackgroundView.bottomAnchor),
                searchHeaderViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                searchHeaderViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ] + constraints + [
                searchResultsViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                searchResultsViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                searchResultsViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ]
        )
    }
    
    private var showsGroupSelector: Bool {
        return SearchGroup.all.count > 1 && ZMUser.selfUser().canSeeServices
    }
    
    @objc private func performSearch() {
        let query = searchHeaderViewController.query
        if groupSelector.group == .people {
            if query.isEmpty {
                searchResultsViewController.mode = .list
            } else {
                searchResultsViewController.mode = .search
                searchResultsViewController.searchForLocalUsers(withQuery: query)
            }
        } else {
            
        }
        emptySearchResultsView.updateStatus(
            searchingForServices: groupSelector.group == .services,
            hasFilter: !query.isEmpty
        )
    }
    
    private func presentProfileViewController(for bareUser: UserType, at indexPath: IndexPath) {
        searchHeaderViewController.tokenField.resignFirstResponder()
        
        guard let cell = searchResultsViewController
            .searchResultsView?
            .collectionView
            .cellForItem(at: indexPath) else { return }
        
        let onDismiss = {
            if self.profilePresenter.keyboardPersistedAfterOpeningProfile {
                self.searchHeaderViewController.tokenField.becomeFirstResponder()
                self.profilePresenter.keyboardPersistedAfterOpeningProfile = false
            }
        }
        profilePresenter.presentProfileViewController(
            for: bareUser,
            in: self,
            from: view.convert(cell.bounds, from: cell),
            onDismiss: onDismiss
        )
    }
}


// MARK: - Add Close Btn
extension AddFriendViewController {
    
    private func setupNavigationBar() {
        if navigationController?.viewControllers.count ?? 0 <= 1 {
            let item = UIBarButtonItem(icon: .cross, target: self, action: #selector(closeTapped))
            item.accessibilityIdentifier = "close"
            item.accessibilityLabel = "general.close".localized
            navigationItem.leftBarButtonItem = item
        }
    }
    
    @objc private func closeTapped() {
        delegate?.addFriendViewControllerWantToDismissByTapX(self)
        dismiss(animated: true)
    }
}


// MARK: - EmptySearchResultsViewDelegate
extension AddFriendViewController: EmptySearchResultsViewDelegate {
    
    func execute(action: EmptySearchResultsViewAction, from: EmptySearchResultsView) {}
}


// MARK: - SearchHeaderViewControllerDelegate
extension AddFriendViewController: SearchHeaderViewControllerDelegate {
    
    func searchHeaderViewControllerDidConfirmAction(_ searchHeaderViewController: SearchHeaderViewController) {
        searchHeaderViewController.resetQuery()
    }
    
    func searchHeaderViewController(_ searchHeaderViewController: SearchHeaderViewController, updatedSearchQuery query: String) {
        searchResultsViewController.cancelPreviousSearch()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        perform(#selector(performSearch), with: nil, afterDelay: 0.2)
    }
}


// MARK: - AddFriendSearchResultsViewControllerDelegate
extension AddFriendViewController: AddFriendSearchResultsViewControllerDelegate {
    
    func addFriendSearchResultsViewController(
        _ viewController: AddFriendSearchResultsViewController,
        didTapOnUser user: UserType,
        indexPath: IndexPath,
        section: SearchResultsViewControllerSection
        ) {
        searchHeaderViewController.tokenField.resignFirstResponder()
        
        if !user.isConnected && !user.isTeamMember {
            presentProfileViewController(for: user, at: indexPath)
        } else if let unboxed = user.zmUser {
            var conversation: ZMConversation?
            ZMUserSession.shared()?.enqueueChanges({
                conversation = unboxed.oneToOneConversation
            }, completionHandler: {
                delay(0.3) {
                    if let conversation = conversation {
                        ZClientViewController.shared?.select(conversation: conversation, focusOnView: true, animated: true)
                    }
                }
            })
        }
    }
    
    func addFriendSearchResultsViewController(_ viewController: AddFriendSearchResultsViewController, wantsToPerformAction action: AddFriendSearchResultsViewController.Action) {
        switch action {
        case .scan:
            let scanVC = ScanForContactViewController()
            navigationController?.pushViewController(scanVC, animated: true)
        case .phoneContacts:
            let inviteContactVC = ContactsViewController()
            navigationController?.pushViewController(inviteContactVC, animated: true)
        }
    }
}
