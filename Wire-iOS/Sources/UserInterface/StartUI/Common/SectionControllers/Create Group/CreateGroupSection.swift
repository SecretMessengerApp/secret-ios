
import Foundation

class CreateGroupSection: NSObject, CollectionViewSectionController {
    
    enum Row {
        case addFriend
        case createGroup
        case createGuestRoom
//        case createHugeGroup
        case inviteAddressbook
    }
    
    private var data: [Row] {
        return ZMUser.selfUser().isTeamMember
            ? [.createGroup, .createGuestRoom]
            : [.addFriend, .createGroup, /*Row.createHugeGroup,*/ .inviteAddressbook]
    }
    
    weak var delegate: SearchSectionControllerDelegate?

    var isHidden: Bool {
        if ZMUser.selfUser() != nil {
            return !ZMUser.selfUser().canCreateConversation
        }else{
            return true
        }
        
//        return ZMUser.selfUser()?.isTeamMember ?? false ? !selfUserIsAuthorized : false
    }
    
    func prepareForUse(in collectionView: UICollectionView?) {
        collectionView?.register(AddFriendCell.self, forCellWithReuseIdentifier: AddFriendCell.zm_reuseIdentifier)
        collectionView?.register(CreateGroupCell.self, forCellWithReuseIdentifier: CreateGroupCell.zm_reuseIdentifier)
//        collectionView?.register(CreateHugeGroupCell.self, forCellWithReuseIdentifier: CreateHugeGroupCell.zm_reuseIdentifier)
        collectionView?.register(CreateGuestRoomCell.self, forCellWithReuseIdentifier: CreateGuestRoomCell.zm_reuseIdentifier)
        collectionView?.register(InviteContactCell.self, forCellWithReuseIdentifier: InviteContactCell.zm_reuseIdentifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch data[indexPath.row] {
        case .addFriend:
            return collectionView.dequeueReusableCell(withReuseIdentifier: AddFriendCell.zm_reuseIdentifier, for: indexPath)
        case .createGroup:
            return collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupCell.zm_reuseIdentifier, for: indexPath)
        case .createGuestRoom:
            return collectionView.dequeueReusableCell(withReuseIdentifier: CreateGuestRoomCell.zm_reuseIdentifier, for: indexPath)
//        case .createHugeGroup:
//            return collectionView.dequeueReusableCell(withReuseIdentifier: CreateHugeGroupCell.zm_reuseIdentifier, for: indexPath)
        case .inviteAddressbook:
            return collectionView.dequeueReusableCell(withReuseIdentifier: InviteContactCell.zm_reuseIdentifier, for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        switch data[indexPath.row] {
        case .addFriend:
            delegate?.searchSectionController(self, didSelectRow: .addFriend, at: indexPath)
        case .createGroup:
            delegate?.searchSectionController(self, didSelectRow: .createGroup, at: indexPath)
        case .createGuestRoom:
            delegate?.searchSectionController(self, didSelectRow: .createGuestRoom, at: indexPath)
//        case .createHugeGroup:
//            delegate?.searchSectionController(self, didSelectRow: .createHugeGroup, at: indexPath)
        case .inviteAddressbook:
            delegate?.searchSectionController(self, didSelectRow: .inviteAddressbook, at: indexPath)
        }
        
    }
    
}
