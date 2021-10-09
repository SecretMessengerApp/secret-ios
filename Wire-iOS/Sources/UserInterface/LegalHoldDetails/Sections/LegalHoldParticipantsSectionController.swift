
import Foundation


private struct LegalHoldParticipantsSectionViewModel {

    let participants: [UserType]
    
    var sectionAccesibilityIdentifier = "label.groupdetails.participants"
    
    var sectionTitle: String {
        return "legalhold.participants.section.title".localized(uppercased: true, args: participants.count)
    }
    
    init(participants: [UserType]) {
        self.participants = participants
    }
    
}

protocol LegalHoldParticipantsSectionControllerDelegate: class {
    
    func legalHoldParticipantsSectionWantsToPresentUserProfile(for user: UserType)
    
}

class LegalHoldParticipantsSectionController: GroupDetailsSectionController {
    
    fileprivate weak var collectionView: UICollectionView?
    private var viewModel: LegalHoldParticipantsSectionViewModel
    private let conversation: ZMConversation
    private var token: AnyObject?
    
    public weak var delegate: LegalHoldParticipantsSectionControllerDelegate?
    
    init(conversation: ZMConversation) {
        viewModel = .init(participants: conversation.sortedActiveParticipants.filter(\.isUnderLegalHold))
        self.conversation = conversation
        super.init()
        
        if let userSession = ZMUserSession.shared() {
            token = UserChangeInfo.add(userObserver: self, for: nil, userSession: userSession)
        }
    }
    
    override func prepareForUse(in collectionView : UICollectionView?) {
        super.prepareForUse(in: collectionView)
        collectionView?.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseIdentifier)
        self.collectionView = collectionView
    }
    
    override var sectionTitle: String {
        return viewModel.sectionTitle
    }
    
    override var sectionAccessibilityIdentifier: String {
        return viewModel.sectionAccesibilityIdentifier
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.participants.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let participant = viewModel.participants[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCell.reuseIdentifier, for: indexPath) as! UserCell
        let showSeparator = (viewModel.participants.count - 1) != indexPath.row
        
        cell.configure(with: participant, conversation: conversation)
        cell.accessoryIconView.isHidden = false
        cell.accessibilityIdentifier = "participants.section.participants.cell"
        cell.showSeparator = showSeparator
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = viewModel.participants[indexPath.row]
        
        delegate?.legalHoldParticipantsSectionWantsToPresentUserProfile(for: user)
    }
    
}

extension LegalHoldParticipantsSectionController: ZMUserObserver {
    
    func userDidChange(_ changeInfo: UserChangeInfo) {
        guard changeInfo.connectionStateChanged || changeInfo.nameChanged || changeInfo.isUnderLegalHoldChanged else { return }
        
        viewModel = .init(participants: conversation.sortedActiveParticipants.filter(\.isUnderLegalHold))
        collectionView?.reloadData()
    }
    
}
