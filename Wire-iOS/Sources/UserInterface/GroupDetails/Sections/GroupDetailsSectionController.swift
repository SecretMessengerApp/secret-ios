
import Foundation

protocol GroupDetailsUserDetailPresenter: class {
    func presentDetails(for user: UserType)
}

protocol GroupDetailsSectionControllerDelegate: GroupDetailsUserDetailPresenter {
    func presentFullParticipantsList(for users: [UserType], in conversation: ZMConversation)
    func callbackWhenUsersUpdate()
}

class GroupDetailsSectionController: NSObject, CollectionViewSectionController {

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
            sectionHeaderView.titleLabel.text = sectionTitle
            sectionHeaderView.accessibilityIdentifier = sectionAccessibilityIdentifier
        }

        return supplementaryView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 48)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 56)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatal("Must be overridden")
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatal("Must be overridden")
    }

    //MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        fatal("Must be overridden")
    }
}
