//
import Foundation

class ConversationCreateNameSectionController: NSObject, CollectionViewSectionController {
    
    typealias Cell = ConversationCreateNameCell
    
    var isHidden: Bool {
        return false
    }
    
    var value: SimpleTextField.Value? {
        return nameCell?.textField.value
    }
    
    private weak var nameCell: Cell?
    private weak var textFieldDelegate: SimpleTextFieldDelegate?
    private var footer = SectionFooter(frame: .zero)
    
    private lazy var footerText: String = {
        let key = "participants.section.name.footer"
        return key.localized(args: ZMConversation.maxParticipants, ZMConversation.maxVideoCallParticipantsExcludingSelf)
    }()
    
    init(delegate: SimpleTextFieldDelegate? = nil) {
        textFieldDelegate = delegate
    }
    
    func prepareForUse(in collectionView: UICollectionView?) {
        collectionView.flatMap(Cell.register)
        collectionView?.register(SectionFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "SectionFooter")
    }
    
    func becomeFirstResponder() {
        nameCell?.textField.becomeFirstResponder()
    }
    
    func resignFirstResponder() {
        nameCell?.textField.resignFirstResponder()
    }
}

extension ConversationCreateNameSectionController {
    
    func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: Cell.self, for: indexPath)
        cell.textField.textFieldDelegate = textFieldDelegate
        nameCell = cell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "SectionFooter", for: indexPath)
        (view as? SectionFooter)?.titleLabel.text = footerText
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard ZMUser.selfUser().hasTeam else { return .zero }
        footer.titleLabel.text = footerText
        footer.size(fittingWidth: collectionView.bounds.width)
        return footer.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        nameCell?.textField.becomeFirstResponder()
    }
}
