// 

protocol SectionListCellType: class {
    var sectionName: String? { get set }
}

extension SectionListCellType {
    var identifier: String {
        let prefix: String

        if let sectionName = sectionName {
            prefix = "\(sectionName) - "
        } else {
            prefix = ""
        }

        return prefix + "conversation_list_cell"
    }
}

final class ConnectRequestsCell : UICollectionViewCell, SectionListCellType {
    var sectionName: String?

    let itemView = ConversationListItemView()

    private var hasCreatedInitialConstraints = false
    private var currentConnectionRequestsCount: Int = 0
    private var conversationListObserverToken: Any?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConnectRequestsCell()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConnectRequestsCell() {
        clipsToBounds = true
        addSubview(itemView)
        updateAppearance()

        if let userSession = ZMUserSession.shared() {
            conversationListObserverToken = ConversationListChangeInfo.add(observer: self, for: ZMConversationList.pendingConnectionConversations(inUserSession: userSession), userSession: userSession)
        }

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


        let connectionRequests = ZMConversationList.pendingConnectionConversations(inUserSession: userSession)

        let newCount: Int = connectionRequests.count

        if newCount != currentConnectionRequestsCount {
            let connectionUsers = connectionRequests.map{ conversation in
                if let conversation = conversation as? ZMConversation {
                    return conversation.connection?.to
                } else {
                    return nil
                }
            }

            if let users = connectionUsers as? [ZMUser] {
                currentConnectionRequestsCount = newCount
                let title = String(format: NSLocalizedString("list.connect_request.people_waiting", comment: ""), newCount)
                itemView.configure(with: NSAttributedString(string: title), subtitle: NSAttributedString(), users: users)
            }
        }
    }

}

extension ConnectRequestsCell: ZMConversationListObserver {
    func conversationListDidChange(_ changeInfo: ConversationListChangeInfo) {
        updateAppearance()
    }
}
