
import Foundation

class ConversationCreateReceiptsSectionController: ConversationCreateSectionController {
    
    typealias Cell = ConversationCreateReceiptsCell

    var toggleAction: ((Bool) -> Void)?

    override func prepareForUse(in collectionView: UICollectionView?) {
        super.prepareForUse(in: collectionView)
        collectionView.flatMap(Cell.register)
        headerHeight = 24
        footerText = "conversation.create.receipts.subtitle".localized
    }
}

extension ConversationCreateReceiptsSectionController {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: Cell.self, for: indexPath)
        self.cell = cell
        cell.setUp()
        cell.configure(with: values)
        cell.action = toggleAction
        return cell
    }
}
