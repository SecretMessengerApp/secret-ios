
import Foundation
import Cartography

final public class CollectionVideoCell: CollectionCell {
    private let videoMessageView = VideoMessageView()

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
        
        videoMessageView.configure(for: message, isInitial: true)
    }
    
    func loadView() {
        
        self.videoMessageView.delegate = self
        self.videoMessageView.clipsToBounds = true
        self.videoMessageView.timeLabelHidden = true
        self.secureContentsView.addSubview(self.videoMessageView)
        
        constrain(self.contentView, self.videoMessageView) { contentView, videoMessageView in
            videoMessageView.edges == contentView.edges
        }
    }

    override var obfuscationIcon: StyleKitIcon {
        return .movie
    }

}

extension CollectionVideoCell: TransferViewDelegate {
    func transferView(_ view: TransferView, didSelect action: MessageAction) {
        delegate?.collectionCell(self, performAction: action)
    }
}
