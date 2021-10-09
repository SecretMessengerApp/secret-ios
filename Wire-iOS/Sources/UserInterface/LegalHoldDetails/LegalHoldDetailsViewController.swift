
import UIKit

final class LegalHoldDetailsViewController: UIViewController {
    
    fileprivate let collectionView = UICollectionView(forGroupedSections: ())
    fileprivate let collectionViewController: SectionCollectionViewController
    fileprivate let conversation: ZMConversation
    
    convenience init?(user: UserType) {
        guard let conversation = user.oneToOneConversation else { return nil }
        self.init(conversation: conversation)
    }
        
    init(conversation: ZMConversation) {
        self.conversation = conversation
        self.collectionViewController = SectionCollectionViewController()
        self.collectionViewController.collectionView = collectionView
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        createConstraints()
        collectionViewController.sections = computeVisibleSections()
        collectionView.accessibilityIdentifier = "list.legalhold"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    static func present(in parentViewController: UIViewController, user: UserType) -> UINavigationController? {
        guard let legalHoldDetailsViewController = LegalHoldDetailsViewController(user: user) else { return nil }

        return legalHoldDetailsViewController.wrapInNavigationControllerAndPresent(from: parentViewController)
    }

    @discardableResult
    static func present(in parentViewController: UIViewController, conversation: ZMConversation) -> UINavigationController {
        let legalHoldDetailsViewController = LegalHoldDetailsViewController(conversation: conversation)

        return legalHoldDetailsViewController.wrapInNavigationControllerAndPresent(from: parentViewController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "legalhold.header.title".localized.localizedUppercase
        view.backgroundColor = UIColor.dynamic(scheme: .background)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem = navigationController?.closeItem()
        updateStatusBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        conversation.verifyLegalHoldSubjects()
    }
    
    fileprivate func setupViews() {
        
        view.addSubview(collectionView)

        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    fileprivate func createConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    fileprivate func computeVisibleSections() -> [CollectionViewSectionController] {
        let headerSection = SingleViewSectionController(view: LegalHoldHeaderView(frame: .zero))
        let legalHoldParticipantsSection = LegalHoldParticipantsSectionController(conversation: conversation)
        legalHoldParticipantsSection.delegate = self
        
        return [headerSection, legalHoldParticipantsSection]
    }
    
}

extension LegalHoldDetailsViewController: LegalHoldParticipantsSectionControllerDelegate {
    
    func legalHoldParticipantsSectionWantsToPresentUserProfile(for user: UserType) {
        let profileViewController = ProfileViewController(user: user, viewer: ZMUser.selfUser(), context: .deviceList)
        show(profileViewController, sender: nil)
    }
    
}
