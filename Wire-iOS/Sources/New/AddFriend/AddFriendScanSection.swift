

import UIKit

protocol AddFriendScanSectionDelegate: class {
     func section(_ section: CollectionViewSectionController, didSelectRow row: AddFriendScanSection.Row, at indexPath: IndexPath)
}

class AddFriendScanSection: NSObject, CollectionViewSectionController {
    
    enum Row {
        case scan
        case phoneContacts
    }
    
    private var data: [Row] {
        return [.scan, .phoneContacts]
    }
    
    var isHidden: Bool { return false }
    
    weak var delegate: AddFriendScanSectionDelegate?
    
    func prepareForUse(in collectionView: UICollectionView?) {
        collectionView?.registerCell(AddFriendScanCell.self)
        collectionView?.registerCell(AddFriendPhoneContactsCell.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch data[indexPath.row] {
        case .scan:
            return collectionView.dequeueCell(AddFriendScanCell.self, for: indexPath)
        case .phoneContacts:
            return collectionView.dequeueCell(AddFriendPhoneContactsCell.self, for: indexPath)
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
        case .scan:
            delegate?.section(self, didSelectRow: .scan, at: indexPath)
        case .phoneContacts:
            delegate?.section(self, didSelectRow: .phoneContacts, at: indexPath)
        }
        
    }
}

private final class AddFriendScanCell: StartUIIconCell {
    
    override func setupViews() {
        super.setupViews()
        icon = .scan
        title = "conversation_list.popover.scan".localized
        isAccessibilityElement = true
        accessibilityLabel = title
        accessibilityIdentifier = "button.searchui.addfriend"
    }
}

private final class AddFriendPhoneContactsCell: StartUIIconCell {
    
    override func setupViews() {
        super.setupViews()
        icon = .addressBook
        title = "peoplepicker.header.contacts".localized
        isAccessibilityElement = true
        accessibilityLabel = title
        accessibilityIdentifier = "button.searchui.addfriend"
    }
}
