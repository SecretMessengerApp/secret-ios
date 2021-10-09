
import Foundation

class DirectorySectionController: SearchSectionController {
    
    var suggestions: [ZMSearchUser] = []
    weak var delegate: SearchSectionControllerDelegate? = nil
    var token: AnyObject? = nil
    weak var collectionView: UICollectionView? = nil
    
    override var isHidden: Bool {
        return self.suggestions.isEmpty
    }
    
    override var sectionTitle: String {
        return "peoplepicker.header.directory".localized
    }
    
    override func prepareForUse(in collectionView : UICollectionView?) {
        super.prepareForUse(in: collectionView)
        
        collectionView?.register(UserCell.self, forCellWithReuseIdentifier: UserCell.zm_reuseIdentifier)
        
        self.token = UserChangeInfo.add(searchUserObserver: self, for: nil, userSession: ZMUserSession.shared()!)
        
        self.collectionView = collectionView
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let user = suggestions[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCell.zm_reuseIdentifier, for: indexPath) as! UserCell
        
        cell.configure(with: user)
        cell.showSeparator = (suggestions.count - 1) != indexPath.row
//        cell.guestIconView.isHidden = true
        cell.accessoryIconView.isHidden = true
        cell.connectButton.isHidden = false
        cell.connectButton.tag = indexPath.row
        cell.connectButton.addTarget(self, action: #selector(connect(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func connect(_ sender: AnyObject) {
        guard let button = sender as? UIButton else { return }
        
        let indexPath = IndexPath(row: button.tag, section: 0)
        let user = suggestions[indexPath.row]
        
        ZMUserSession.shared()?.enqueueChanges {
            let messageText = "missive.connection_request.default_message".localized(args: user.displayName, ZMUser.selfUser().name ?? "")
            user.connect(message: messageText)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = suggestions[indexPath.row]
        delegate?.searchSectionController(self, didSelectUser: user, at: indexPath)
    }
    
}

extension DirectorySectionController: ZMUserObserver {
    
    func userDidChange(_ changeInfo: UserChangeInfo) {
        guard changeInfo.connectionStateChanged else { return }
        
        collectionView?.reloadData()
    }
    
}
