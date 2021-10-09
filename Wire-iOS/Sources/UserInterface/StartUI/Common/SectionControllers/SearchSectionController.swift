
import Foundation

protocol SearchSectionControllerDelegate: class {
    
    func searchSectionController(_ searchSectionController: CollectionViewSectionController, didSelectUser user: UserType, at indexPath: IndexPath)
    
    func searchSectionController(_ searchSectionController: CollectionViewSectionController, didSelectConversation conversation: ZMConversation, at indexPath: IndexPath)
    
    func searchSectionController(_ searchSectionController: CollectionViewSectionController, didSelectRow row: CreateGroupSection.Row, at indexPath: IndexPath)
    
}

class SearchSectionController: NSObject, CollectionViewSectionController {
    
    var isHidden: Bool {
        return false
    }
    
    var sectionTitle: String {
        return ""
    }
    
    var sectionAccessibilityIdentifier: String {
        return "section_header"
    }
        
    func prepareForUse(in collectionView : UICollectionView?) {
        collectionView?.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath)
        
        if let sectionHeaderView = supplementaryView as? SectionHeader {
            sectionHeaderView.titleLabel.text = sectionTitle.localizedUppercase
            sectionHeaderView.accessibilityIdentifier = sectionAccessibilityIdentifier
        }
        
        return supplementaryView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 48)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: CGFloat.StartUI.CellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // Workaround for when a cell is created inside an animation block. In this case it happens
        // when the keyboard is animating away which will change the height of the collection view
        // and therefore reveal more cells.
        UIView.performWithoutAnimation {
            cell.layoutIfNeeded()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatal("Must be overridden")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatal("Must be overridden")
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
        // NOTE: workaround for regression in Swift 5
        // https://bugs.swift.org/browse/SR-2919
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // NOTE: workaround for regression in Swift 5
        // https://bugs.swift.org/browse/SR-2919
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // NOTE: workaround for regression in Swift 5
        // https://bugs.swift.org/browse/SR-2919
    }
    
}

