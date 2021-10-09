
import Foundation

class ConversationCreateErrorSectionController: NSObject, CollectionViewSectionController {
    
    typealias Cell = ConversationCreateErrorCell
    
    weak var errorCell: Cell?
    
    var isHidden: Bool {
        return false
    }
    
    func prepareForUse(in collectionView: UICollectionView?) {
        collectionView.flatMap(Cell.register)
    }
    
    func clearError() {
        errorCell?.label.text = nil
    }
    
    func displayError(_ error: Error) {
        errorCell?.label.text = error.localizedDescription.localizedUppercase

    }
}

extension ConversationCreateErrorSectionController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: Cell.self, for: indexPath)
        errorCell = cell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 56)
    }
}

