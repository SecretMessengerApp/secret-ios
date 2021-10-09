
import Foundation
import WireDataModel

final class TopPeopleLineCollectionViewController: NSObject {

    var topPeople = [ZMConversation]()

    weak var delegate: TopPeopleLineCollectionViewControllerDelegate?

    private func conversation(at indexPath: IndexPath) -> ZMConversation {
        return topPeople[indexPath.item % topPeople.count]
    }
}

// MARK: - Collection View Data Source

extension TopPeopleLineCollectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topPeople.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: TopPeopleCell.self, for: indexPath)
        cell.conversation = conversation(at: indexPath)
        return cell
    }
}

// MARK: - Collection View Delegate

extension TopPeopleLineCollectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let conversation = self.conversation(at: indexPath)
        delegate?.topPeopleLineCollectionViewControllerDidSelect(conversation)
    }

}

// MARK: - Flow Layout

extension TopPeopleLineCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 6, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 56, height: 78)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}
