
import Foundation


class ContactsSectionController : SearchSectionController {
    
    var   contacts: [ZMUser] = []
    var selection: UserSelection? = nil {
        didSet {
            selection?.add(observer: self)
        }
    }
    var participantsWay: SearchResultsViewControllerParticipantsWay = SearchResultsViewControllerParticipantsWay.default
    var allowsSelection: Bool {
        return participantsWay != .default
    }
    weak var delegate: SearchSectionControllerDelegate? = nil
    weak var collectionView: UICollectionView? = nil
    
    deinit {
        selection?.remove(observer: self)
    }
    
    override func prepareForUse(in collectionView : UICollectionView?) {
        super.prepareForUse(in: collectionView)
        
        collectionView?.register(UserCell.self, forCellWithReuseIdentifier: UserCell.zm_reuseIdentifier)
        
        self.collectionView = collectionView
    }
    
    override var isHidden: Bool {
        return contacts.isEmpty
    }
    
    var title: String = ""
    
    override var sectionTitle: String {
        return title
    }
    
    override var sectionAccessibilityIdentifier: String {
        return "label.search.participants"
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let user = contacts[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCell.zm_reuseIdentifier, for: indexPath) as! UserCell
        cell.avatar.isEnabled = false
        cell.configure(with: user)
        cell.showSeparator = (contacts.count - 1) != indexPath.row
        cell.checkmarkIconView.isHidden = !allowsSelection
        cell.accessoryIconView.isHidden = true
        
        let selected = selection?.users.contains(user) ?? false
        cell.isSelected = selected
        
        if selected  {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return !(selection?.hasReachedLimit ?? false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.participantsWay == .changeCreator || self.participantsWay == .select {
            selection?.removeAll()
        }
        let user = contacts[indexPath.row]
        selection?.add(user)
        
        delegate?.searchSectionController(self, didSelectUser: user, at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let user = contacts[indexPath.row]
        selection?.remove(user)
    }
    
}

extension ContactsSectionController: UserSelectionObserver {
    
    func userSelection(_ userSelection: UserSelection, wasReplacedBy users: [ZMUser]) {
        collectionView?.reloadData()
    }
    
    func userSelection(_ userSelection: UserSelection, didAddUser user: ZMUser) {
        collectionView?.reloadData()
    }
    
    func userSelection(_ userSelection: UserSelection, didRemoveUser user: ZMUser) {
        collectionView?.reloadData()
    }
    
}
