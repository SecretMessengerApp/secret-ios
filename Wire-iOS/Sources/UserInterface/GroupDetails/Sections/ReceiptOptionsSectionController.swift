
import Foundation

class ReceiptOptionsSectionController: GroupDetailsSectionController {

    
    private let emptySectionHeaderHeight: CGFloat = 24

    let cellReuseIdentifier: String = GroupDetailsReceiptOptionsCell.zm_reuseIdentifier

    // MARK: - Properties

    private let conversation: ZMConversation
    private let syncCompleted: Bool

    private var footerView = SectionFooter(frame: .zero)
    private weak var presentingViewController: UIViewController?
    
    override var isHidden: Bool {
        return !(ZMUser.selfUser()?.canModifyReadReceiptSettings(in: conversation) ?? false)
    }

    init(conversation: ZMConversation,
        syncCompleted: Bool,
        collectionView: UICollectionView,
        presentingViewController: UIViewController) {
        self.conversation = conversation
        self.syncCompleted = syncCompleted
        self.presentingViewController = presentingViewController

        collectionView.register(SectionFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "SectionFooter")
    }

    // MARK: - Collection View
    
    override var sectionTitle: String {
        return ""
    }

    override func prepareForUse(in collectionView: UICollectionView?) {
        super.prepareForUse(in: collectionView)

        collectionView.flatMap(GroupDetailsReceiptOptionsCell.register)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 56)
    }


    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! GroupDetailsReceiptOptionsCell
        
        cell.configure(with: conversation)
        cell.action = { [weak self] enabled in
            guard let userSession = ZMUserSession.shared(), let conversation = self?.conversation else { return }
            
            cell.isUserInteractionEnabled = false
            conversation.setEnableReadReceipts(enabled, in: userSession, { result in
                cell.isUserInteractionEnabled = true
                
                switch result {
                case .failure(_):
                    cell.configure(with: conversation)
                    self?.presentingViewController?.present(UIAlertController.checkYourConnection(), animated: true)
                default:
                    break
                }
            })
            
        }
        
        cell.showSeparator = false
        cell.isUserInteractionEnabled = syncCompleted
        cell.alpha = syncCompleted ? 1 : 0.48

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    ///MARK: - header

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: emptySectionHeaderHeight)
    }

    ///MARK: - footer

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

        footerView.titleLabel.text = "group_details.receipt_options_cell.description".localized
        footerView.size(fittingWidth: collectionView.bounds.width)
        return footerView.bounds.size
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter else { return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)}

        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "SectionFooter", for: indexPath)
        (view as? SectionFooter)?.titleLabel.text = "group_details.receipt_options_cell.description".localized
        return view
    }
    
}
