

import Foundation
import Cartography


final public class CollectionFileCell: CollectionCell {
    private let fileTransferView = FileTransferView()
    private let headerView = CollectionCellHeader()
    
    override func updateForMessage(changeInfo: MessageChangeInfo?) {
        super.updateForMessage(changeInfo: changeInfo)
        
        guard let message = self.message else {
            return
        }
        headerView.message = message
        fileTransferView.configure(for: message, isInitial: changeInfo == .none)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadView()
    }
    
    func loadView() {
        self.fileTransferView.delegate = self
        self.fileTransferView.layer.cornerRadius = 4
        self.fileTransferView.clipsToBounds = true

        self.secureContentsView.layoutMargins = UIEdgeInsets(top: 16, left: 4, bottom: 4, right: 4)
        self.secureContentsView.addSubview(self.headerView)
        self.secureContentsView.addSubview(self.fileTransferView)

        constrain(self.secureContentsView, self.fileTransferView, self.headerView) { contentView, fileTransferView, headerView in
            headerView.top == contentView.topMargin
            headerView.leading == contentView.leadingMargin + 12
            headerView.trailing == contentView.trailingMargin - 12
            
            fileTransferView.top == headerView.bottom + 4
            
            fileTransferView.left == contentView.leftMargin
            fileTransferView.right == contentView.rightMargin
            fileTransferView.bottom == contentView.bottomMargin
        }
    }

    override var obfuscationIcon: StyleKitIcon {
        return .document
    }

}

extension CollectionFileCell: TransferViewDelegate {
    func transferView(_ view: TransferView, didSelect action: MessageAction) {
        delegate?.collectionCell(self, performAction: action)
    }
}
