
import Foundation

protocol ParticipantsCellConfigurable: Reusable {
    func configure(with rowType: ParticipantsRowType, conversation: ZMConversation, showSeparator: Bool)
}

enum ParticipantsRowType {
    case user(UserType)
    case showAll(Int)
    
    init(_ user: UserType) {
        self = .user(user)
    }
    
    var cellType: ParticipantsCellConfigurable.Type {
        switch self {
        case .user: return UserCell.self
        case .showAll: return ShowAllParticipantsCell.self
        }
    }
}

private struct ParticipantsSectionViewModel {
    static private let maxParticipants = 7
    let rows: [ParticipantsRowType]
    let participants: [UserType]
    private let membersCount: Int
    
   
    private var canSeeMembersCount: Bool {
        return membersCount != 0
    }
    
    
    var sectionAccesibilityIdentifier = "label.groupdetails.participants"
    
    var sectionTitle: String {
        if canSeeMembersCount {
            return "participants.section.participants".localized(args: membersCount).uppercased()
        } else {
            return "participants.all.title".localized
        }
    }

    init(participants: [UserType], membersCount: Int) {
        self.participants = participants
        self.membersCount = membersCount
        rows = ParticipantsSectionViewModel.computeRows(participants, membersCount: membersCount)
    }
    
    static func computeRows(_ participants: [UserType], membersCount: Int) -> [ParticipantsRowType] {
        guard participants.count > maxParticipants else { return participants.map(ParticipantsRowType.init) }
        return participants[0..<5].map(ParticipantsRowType.init) + [.showAll(membersCount)]
    }
}

extension UserCell: ParticipantsCellConfigurable {
    func configure(with rowType: ParticipantsRowType, conversation: ZMConversation, showSeparator: Bool) {
        guard case let .user(user) = rowType else { preconditionFailure() }
        configure(with: user, conversation: conversation)
        accessoryIconView.isHidden = false
        accessibilityIdentifier = "participants.section.participants.cell"
        self.showSeparator = showSeparator
    }
}

class ParticipantsSectionController: GroupDetailsSectionController {
    
    private weak var delegate: GroupDetailsSectionControllerDelegate?
    private let viewModel: ParticipantsSectionViewModel
    private let conversation: ZMConversation
    private var token: AnyObject?
    private var conversationToken: AnyObject?
    
    init(participants: [UserType], conversation: ZMConversation, delegate: GroupDetailsSectionControllerDelegate) {
        var membersCount = 0
        if conversation.creator.isSelfUser || conversation.showMemsum {
            membersCount = conversation.membersCount
        }
        viewModel = .init(participants: participants,
                          membersCount: membersCount)
        self.conversation = conversation
        self.delegate = delegate
        super.init()
        if self.conversation.conversationType != .hugeGroup {
            token = UserChangeInfo.add(userObserver: self, for: nil, userSession: ZMUserSession.shared()!)
        }
        //conversationToken = ConversationChangeInfo.add(observer: self, for: conversation)
    }
    
    override func prepareForUse(in collectionView : UICollectionView?) {
        super.prepareForUse(in: collectionView)
        collectionView?.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseIdentifier)
        collectionView?.register(ShowAllParticipantsCell.self, forCellWithReuseIdentifier: ShowAllParticipantsCell.reuseIdentifier)
    }
    
    override var sectionTitle: String {
        return viewModel.sectionTitle
    }
    
    override var sectionAccessibilityIdentifier: String {
        return viewModel.sectionAccesibilityIdentifier
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.rows.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let configuration = viewModel.rows[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: configuration.cellType.reuseIdentifier, for: indexPath) as! ParticipantsCellConfigurable & UICollectionViewCell
        cell.contentView.backgroundColor = .dynamic(scheme: .cellBackground)
        let showSeparator = (viewModel.rows.count - 1) != indexPath.row
        cell.configure(with: configuration, conversation: conversation, showSeparator: showSeparator)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch viewModel.rows[indexPath.row] {
        case .user(let bareUser):
            guard let user = bareUser as? ZMUser else { return }
            delegate?.presentDetails(for: user)
        case .showAll:
            delegate?.presentFullParticipantsList(for: viewModel.participants, in: conversation)
        }
    }
    
}

extension ParticipantsSectionController: ZMUserObserver {
    
    func userDidChange(_ changeInfo: UserChangeInfo) {
        guard changeInfo.connectionStateChanged || changeInfo.nameChanged else { return }
        delegate?.callbackWhenUsersUpdate()
    }
    
}
