
import Foundation
import Cartography

final public class CollectionAudioCell: CollectionCell {
    private let audioMessageView = AudioMessageView()
    private let headerView = CollectionCellHeader()

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadView()
    }
    
    override func updateForMessage(changeInfo: MessageChangeInfo?) {
        super.updateForMessage(changeInfo: changeInfo)
        
        guard let message = self.message else {
            return
        }
        
        headerView.message = message
        audioMessageView.configure(for: message, isInitial: true)
    }
        
    func loadView() {
        self.audioMessageView.delegate = self
        self.audioMessageView.layer.cornerRadius = 4
        self.audioMessageView.clipsToBounds = true
        
        self.secureContentsView.layoutMargins = UIEdgeInsets(top: 16, left: 4, bottom: 4, right: 4)
        self.secureContentsView.addSubview(self.headerView)
        self.secureContentsView.addSubview(self.audioMessageView)
        
        constrain(self.secureContentsView, self.audioMessageView, self.headerView) { contentView, audioMessageView, headerView in
            headerView.top == contentView.topMargin
            headerView.leading == contentView.leadingMargin + 12
            headerView.trailing == contentView.trailingMargin - 12
            
            audioMessageView.top == headerView.bottom + 4
            
            audioMessageView.left == contentView.leftMargin
            audioMessageView.right == contentView.rightMargin
            audioMessageView.bottom == contentView.bottomMargin
        }
    }

    override var obfuscationIcon: StyleKitIcon {
        return .microphone
    }

}

extension CollectionAudioCell: TransferViewDelegate {
    func transferView(_ view: TransferView, didSelect action: MessageAction) {
        delegate?.collectionCell(self, performAction: action)
    }
}
