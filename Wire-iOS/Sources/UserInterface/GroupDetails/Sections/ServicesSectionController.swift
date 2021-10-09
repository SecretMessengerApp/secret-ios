
import Foundation

class ServicesSectionController: GroupDetailsSectionController {
    
    private weak var delegate: GroupDetailsSectionControllerDelegate?
    private let serviceUsers: [UserType]
    private let conversation: ZMConversation
    
    init(serviceUsers: [UserType], conversation: ZMConversation, delegate: GroupDetailsSectionControllerDelegate) {
        self.serviceUsers = serviceUsers
        self.conversation = conversation
        self.delegate = delegate
    }
    
    override func prepareForUse(in collectionView : UICollectionView?) {
        super.prepareForUse(in: collectionView)
        
        collectionView?.register(UserCell.self, forCellWithReuseIdentifier: UserCell.zm_reuseIdentifier)
    }
    
    override var sectionTitle: String {
        return "participants.section.services".localized(uppercased: true, args: serviceUsers.count)
    }
    
    override var sectionAccessibilityIdentifier: String {
        return "label.groupdetails.services"
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return serviceUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let user = serviceUsers[indexPath.row]
        let cell = collectionView.dequeueReusableCell(ofType: UserCell.self, for: indexPath)
        
        cell.configure(with: user, conversation: conversation)
        cell.showSeparator = (serviceUsers.count - 1) != indexPath.row
        cell.accessoryIconView.isHidden = false
        cell.accessibilityIdentifier = "participants.section.services.cell"
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = serviceUsers[indexPath.row] as? ZMUser else { return }
        delegate?.presentDetails(for: user)
    }
    
}
