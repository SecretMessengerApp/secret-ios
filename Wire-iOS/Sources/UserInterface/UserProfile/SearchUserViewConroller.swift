
import Foundation

final class SearchUserViewConroller: UIViewController {

    private var searchDirectory: SearchDirectory!
    private weak var profileViewControllerDelegate: ProfileViewControllerDelegate?
    private let userId: UUID
    private var pendingSearchTask: SearchTask? = nil

    /// flag for handleSearchResult. Only allow to display the result once
    private var resultHandled = false

    public init(userId: UUID, profileViewControllerDelegate: ProfileViewControllerDelegate?) {
        self.userId = userId
        self.profileViewControllerDelegate = profileViewControllerDelegate

        super.init(nibName: nil, bundle: nil)

        if let session = ZMUserSession.shared() {
            searchDirectory = SearchDirectory(userSession: session)
        }

        view.backgroundColor = UIColor.dynamic(scheme: .background)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        searchDirectory?.tearDown()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let cancelItem = UIBarButtonItem(icon: .cross, target: self, action: #selector(cancelButtonTapped))
        cancelItem.accessibilityIdentifier = "CancelButton"
        cancelItem.accessibilityLabel = "general.cancel".localized
        navigationItem.rightBarButtonItem = cancelItem

        showLoadingView = true

        if let task = searchDirectory?.lookup(userId: userId) {
            task.onResult({ [weak self] in
                self?.handleSearchResult(searchResult: $0, isCompleted: $1)
            })
            task.start()

            pendingSearchTask = task
        }

    }

    private func handleSearchResult(searchResult: SearchResult, isCompleted: Bool) {
        guard !resultHandled,
              isCompleted
            else { return }

        let profileUser: UserType?
        if let searchUser = searchResult.directory.first {
            profileUser = searchUser
        } else if let memberUser = searchResult.teamMembers.first?.user {
            profileUser = memberUser
        } else {
            profileUser = nil
        }


        if let profileUser = profileUser {
            let profileViewController = ProfileViewController(user: profileUser, viewer: ZMUser.selfUser(), context: .profileViewer) ///TODO: context
            profileViewController.delegate = profileViewControllerDelegate

            navigationController?.setViewControllers([profileViewController], animated: true)
            resultHandled = true
        } else if isCompleted {
            presentInvalidUserProfileLinkAlert(okActionHandler: { [weak self] (_) in
                self?.dismiss(animated: true)
            })
        }
    }

    // MARK: - Actions

    @objc private func cancelButtonTapped(sender: AnyObject?) {
        pendingSearchTask?.cancel()
        pendingSearchTask = nil

        dismiss(animated: true)
    }
}

