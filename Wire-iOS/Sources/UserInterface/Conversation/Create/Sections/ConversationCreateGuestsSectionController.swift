
import Foundation

class ConversationCreateGuestsSectionController: ConversationCreateSectionController {
    
    typealias Cell = ConversationCreateGuestsCell
    
    var toggleAction: ((Bool) -> Void)?
    
    override func prepareForUse(in collectionView: UICollectionView?) {
        super.prepareForUse(in: collectionView)
        collectionView.flatMap(Cell.register)
        headerHeight = 40
        footerText = "conversation.create.guests.subtitle".localized
    }
}

extension ConversationCreateGuestsSectionController {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: Cell.self, for: indexPath)
        self.cell = cell
        cell.setUp()
        cell.configure(with: values)
        cell.action = toggleAction
        return cell
    }
}
