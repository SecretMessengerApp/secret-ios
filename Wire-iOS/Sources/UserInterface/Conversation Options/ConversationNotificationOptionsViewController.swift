//
import Foundation

final class ConversationNotificationOptionsViewController: UIViewController {
    
    private var items: [MutedMessageTypes] = [.none, .regular, .all]
    
    private let conversation: ZMConversation
    private let userSession: ZMUserSession
    private var observerToken: Any! = nil
    
    public weak var dismisser: ViewControllerDismisser?
    
    private let collectionViewLayout = UICollectionViewFlowLayout()
    
    private lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
    }()
    
    // MARK: - Initialization
    
    public init(conversation: ZMConversation, userSession: ZMUserSession) {
        self.conversation = conversation
        self.userSession = userSession
        super.init(nibName: nil, bundle: nil)
        observerToken = ConversationChangeInfo.add(observer: self, for: conversation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "group_details.notification_options_cell.title".localized(uppercased: true)
        navigationItem.rightBarButtonItem = navigationController?.closeItem()
        
        configureSubviews()
        configureConstraints()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return wr_supportedInterfaceOrientations
    }
    
    private func configureSubviews() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.dynamic(scheme: .background)
        collectionView.alwaysBounceVertical = true
        
        collectionViewLayout.minimumLineSpacing = 0
        
        CheckmarkCell.register(in: collectionView)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        collectionView.register(SectionFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "SectionFooter")
    }
    
    private func configureConstraints() {
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.fitInSuperview()
    }
}


// MARK: - Table View

extension ConversationNotificationOptionsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = items[indexPath.row]
        let cell = collectionView.dequeueReusableCell(ofType: CheckmarkCell.self, for: indexPath)

        cell.title = item.localizationKey?.localized
        cell.showCheckmark = item == conversation.mutedMessageTypes
        cell.showSeparator = indexPath.row < (items.count - 1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath)
            return view
        } else {
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "SectionFooter", for: indexPath) as? SectionFooter else { return UICollectionReusableView(frame: .zero) }
            view.titleLabel.text = "group_details.notification_options_cell.description".localized
            return view
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "SectionFooter", for: IndexPath(item: 0, section: section)) as? SectionFooter else { return .zero }
        view.titleLabel.text = "group_details.notification_options_cell.description".localized
        view.size(fittingWidth: collectionView.bounds.width)
        return view.bounds.size
    }
    
    // MARK: Saving Changes
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedItem = items[indexPath.row]
        
        guard selectedItem != conversation.mutedMessageTypes else { return }
        updateMutedMessageTypes(selectedItem)
    }
    
    private func updateMutedMessageTypes(_ types: MutedMessageTypes) {
        
        userSession.performChanges {
            self.conversation.mutedMessageTypes = types
        }
    }
    
    // MARK: Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 32)
    }
    
}

extension ConversationNotificationOptionsViewController: ZMConversationObserver {
    func conversationDidChange(_ changeInfo: ConversationChangeInfo) {
        guard changeInfo.mutedMessageTypesChanged else { return }
        collectionView.reloadData()
    }
}


extension MutedMessageTypes {
    
    var localizationKey: String? {
        let base = "meta.menu.configure_notification.button_"
        switch self {
        case .none:         return base + "everything"
        case .regular:      return base + "mentions_and_replies"
        case .all:          return base + "nothing"
        default:            return nil
        }
    }
}
