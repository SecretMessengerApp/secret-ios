
final class NoDisturbedConversationsCell : UICollectionViewCell, SectionListCellType {
    
    var sectionName: String?

    let itemView = ConversationListItemView()

    private var hasCreatedInitialConstraints = false
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
        if let img = UIImage.init(named: "no_disturbed_conversation_icon") {
            self.itemView.configAvatarImage(image: img)
        }
        updateAppearance()

        conversationDirectoryToken = ZMUserSession.shared()?.conversationDirectory.addObserver(self)
        collapsedObserver = SettingsObserver(key: .topConversationCollapsed, changed: { [weak self] (_, _) in
            self?.updateAppearance()
        })
        setNeedsUpdateConstraints()
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

        let noDisturdedConversations = ZMConversationList.noDisturdedConversations(inUserSession: userSession)
        let righttext = "(\(noDisturdedConversations.count))"

        let title = "list.section.conversation.no_disturbe".localized.localized
        
        itemView.configure(with: NSAttributedString(string: title), subtitle: NSAttributedString())
        itemView.setRightText(text: righttext)
    }
    
    

}

extension NoDisturbedConversationsCell: ConversationDirectoryObserver {
    func conversationDirectoryDidChange(_ changeInfo: ConversationDirectoryChangeInfo) {
        updateAppearance()
    }
}
