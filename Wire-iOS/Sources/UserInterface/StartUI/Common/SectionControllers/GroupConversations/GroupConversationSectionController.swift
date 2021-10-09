
import Foundation

class GroupConversationsSectionController: SearchSectionController {
    
    var groupConversations: [ZMConversation] = []
    var title: String = ""
    weak var delegate: SearchSectionControllerDelegate? = nil
    
    override var isHidden: Bool {
        return groupConversations.isEmpty
    }
    
    override var sectionTitle: String {
        return title
    }
    
    override var sectionAccessibilityIdentifier: String {
        return "label.search.group_conversation"
    }
    
    override func prepareForUse(in collectionView: UICollectionView?) {
        collectionView?.register(GroupConversationCell.self, forCellWithReuseIdentifier: GroupConversationCell.zm_reuseIdentifier)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupConversations.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let conversation = groupConversations[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupConversationCell.zm_reuseIdentifier, for: indexPath) as! GroupConversationCell
        
        cell.configure(conversation: conversation)
        cell.separator.isHidden = (groupConversations.count - 1) == indexPath.row
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let conversation = groupConversations[indexPath.row]
        
        delegate?.searchSectionController(self, didSelectConversation: conversation, at: indexPath)
    }
        
    
}
