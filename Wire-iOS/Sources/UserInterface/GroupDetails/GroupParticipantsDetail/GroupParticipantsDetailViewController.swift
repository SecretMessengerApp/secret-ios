
import UIKit
import MJRefresh

final class GroupParticipantsDetailViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    private let collectionView = UICollectionView(forGroupedSections: ())
    private let searchViewController = SearchHeaderViewController(userSelection: .init())
    private let viewModel: GroupParticipantsDetailViewModel
    
    // used for scrolling and fading selected cells
    private var firstLayout = true
    private var firstLoad = true
    
    weak var delegate: GroupDetailsUserDetailPresenter?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return wr_supportedInterfaceOrientations
    }
    
    init(participants: [UserType], selectedParticipants: [UserType], conversation: ZMConversation) {
        if conversation.conversationType == .hugeGroup {
            viewModel = HugeGroupParticipantsDetailViewModel(
                conversation: conversation,
                collectionView: collectionView
            )
        } else {
            viewModel = GroupParticipantsDetailViewModel(
                participants: participants,
                selectedParticipants: selectedParticipants,
                conversation: conversation
            )
        }

        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let context = ZMUserSession.shared()?.managedObjectContext {
            NotificationInContext(name: .bgpMemberDidCancelAllRequest, context: context.notificationContext, object: (1) as AnyObject?, userInfo: nil).post()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let context = ZMUserSession.shared()?.managedObjectContext {
            NotificationInContext(name: .bgpMemberDidCancelAllRequest, context: context.notificationContext, object: (0) as AnyObject?, userInfo: nil).post()
        }
        
        setupViews()
        createConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if firstLayout {
            firstLayout = false
            scrollToFirstHighlightedUser()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstLoad = false
    }
    
    private func setupViews() {
        addToSelf(searchViewController)
        searchViewController.view.translatesAutoresizingMaskIntoConstraints = false
        searchViewController.delegate = viewModel
        viewModel.participantsDidChange = collectionView.reloadData
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset.top = 0
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SelectedUserCell.self, forCellWithReuseIdentifier: SelectedUserCell.reuseIdentifier)
        collectionView.accessibilityIdentifier = "group_details.full_list"
        if viewModel.conversation.showMemsum || viewModel.conversation.creator.isSelfUser {
            title = "participants.section.participants".localized(args: viewModel.conversation.membersCount).uppercased()
        } else {
            title = "participants.all.title".localized
        }
        
        view.backgroundColor = UIColor.dynamic(scheme: .background)
        navigationItem.rightBarButtonItem = navigationController?.closeItem()
    }
    
    private func createConstraints() {
        NSLayoutConstraint.activate([
            searchViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            searchViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: searchViewController.view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func scrollToFirstHighlightedUser() {
        if let idx = viewModel.indexOfFirstSelectedParticipant {
            let indexPath = IndexPath(row: idx, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout & UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if viewModel.participants.count > indexPath.row,
            let user = viewModel.participants[indexPath.row] as? ConversationBGPMemberModel {
            user.cancelRequestPreviewProfileImage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedUserCell.reuseIdentifier, for: indexPath) as! SelectedUserCell
        let user = viewModel.participants[indexPath.row]
        
        cell.configure(
            with: .user(user),
            conversation: viewModel.conversation,
            showSeparator: viewModel.participants.count - 1 != indexPath.row
        )
        
        cell.configureContentBackground(preselected: viewModel.isUserSelected(user), animated: firstLoad)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = viewModel.participants[indexPath.row]
        delegate?.presentDetails(for: user)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.bounds.size.width, height: 56)
    }
}

/// HugeGroup
extension GroupParticipantsDetailViewController {
    

    @objc func removeParticipant(with participant: ZMUser) {
        (viewModel as! HugeGroupParticipantsDetailViewModel).removeParticipant(with: participant)
    }
    
}

private class SelectedUserCell: UserCell {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted
                ? .dynamic(scheme: .cellSelectedBackground)
                : .clear
        }
   }

    func configureContentBackground(preselected: Bool, animated: Bool) {
        contentView.backgroundColor = .clear
        guard preselected else { return }
        
        let changes: () -> () = {
            self.contentView.backgroundColor = UIColor.from(scheme: .cellSeparator)
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0.5,
                options: .curveLinear,
                animations: changes
            )
        } else {
            changes()
        }
    }
}
