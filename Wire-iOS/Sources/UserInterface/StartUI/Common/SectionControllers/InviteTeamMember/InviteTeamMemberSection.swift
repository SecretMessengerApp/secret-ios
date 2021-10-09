
import Foundation

protocol InviteTeamMemberSectionDelegate: class {
    func inviteSectionDidRequestTeamManagement()
}

class InviteTeamMemberSection: NSObject, CollectionViewSectionController {
    
    var team: Team?
    weak var delegate: InviteTeamMemberSectionDelegate?
    
    init(team: Team?) {
        super.init()
        self.team = team
    }
    
    func prepareForUse(in collectionView: UICollectionView?) {
        collectionView?.register(InviteTeamMemberCell.self, forCellWithReuseIdentifier: InviteTeamMemberCell.zm_reuseIdentifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    var isHidden: Bool {
        return team?.members.count > 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: InviteTeamMemberCell.zm_reuseIdentifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 56)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.inviteSectionDidRequestTeamManagement()
    }
    
}
