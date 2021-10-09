
import Foundation

class ConversationCreateOptionsSectionController: ConversationCreateSectionController {
    
    typealias Cell = ConversationCreateOptionsCell
    
    var tapHandler: ((Bool) -> Void)?
    
    override func prepareForUse(in collectionView: UICollectionView?) {
        collectionView.flatMap(Cell.register)
    }
}


extension ConversationCreateOptionsSectionController {
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: Cell.self, for: indexPath)
        self.cell = cell
        cell.setUp()
        cell.configure(with: values)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = cell as? Cell else { return }
        cell.expanded.toggle()
        tapHandler?(cell.expanded)
    }
}
