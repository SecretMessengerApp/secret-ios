
final class TopConversaionsCell : UICollectionViewCell, SectionListCellType {
    
    var sectionName: String?

    let itemView = ConversationListItemView()

    private var hasCreatedInitialConstraints = false
    private var currentExcludeUnreadTopConversationsCount: Int = 0
    private var conversationDirectoryToken: Any?
    private var collapsedObserver: Any?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTopConversaionsCell()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTopConversaionsCell() {
        clipsToBounds = true
        addSubview(itemView)
        if let img = UIImage.init(named: "top_conversation_icon") {
            self.itemView.configAvatarImage(image: img)
        }
        updateAppearance()

        conversationDirectoryToken = ZMUserSession.shared()?.conversationDirectory.addObserver(self)
        collapsedObserver = SettingsObserver(key: .topConversationCollapsed, changed: { [weak self] (_, _) in
            self?.updateAppearance()
        })
        setNeedsUpdateConstraints()
    }
    
    func rightImage() -> UIImage? {
        let collapsed: Bool = Settings.shared[.topConversationCollapsed] ?? false
        if !collapsed {
            return UIImage.init(named: "top_conversation_up")
        } else {
            return UIImage.init(named: "top_conversation_down")
        }
    }

    override var accessibilityIdentifier: String? {
        get {
            return identifier
        }
        set {
            // no op
        }
    }


    override func updateConstraints() {
        if !hasCreatedInitialConstraints {
            hasCreatedInitialConstraints = true
            itemView.translatesAutoresizingMaskIntoConstraints = false
            itemView.fitInSuperview()
        }
        super.updateConstraints()
    }

    private func updateItemViewSelected() {
        itemView.selected = isSelected || isHighlighted
    }

    override var isSelected: Bool {
        didSet {
            if isIPadRegular() {
                updateItemViewSelected()
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            if isIPadRegular() {
                updateItemViewSelected()
            } else {
                itemView.selected = isHighlighted
            }
        }
    }


    private
    func updateAppearance() {
        guard let userSession = ZMUserSession.shared() else { return }

        let excludeUnreadTopConversations = ZMConversationList.excludeUnreadTopConversations(inUserSession: userSession)

        let count: Int = excludeUnreadTopConversations.count

        currentExcludeUnreadTopConversationsCount = count
        
        let title = "\(count)" + "list.section.conversation.list".localized
        
        itemView.configure(with: NSAttributedString(string: title), subtitle: NSAttributedString())
        itemView.setupRightImage(rightImage(), false)
    }

}

extension TopConversaionsCell: ConversationDirectoryObserver {
    func conversationDirectoryDidChange(_ changeInfo: ConversationDirectoryChangeInfo) {
        updateAppearance()
    }
}
