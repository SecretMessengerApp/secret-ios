

import Foundation
import Cartography


private let zmLog = ZMSLog(tag: "UI")

final public class CollectionImageCell: CollectionCell {
    
    static let maxCellSize: CGFloat = 100

    override var message: ZMConversationMessage? {
        didSet {
            loadImage()
        }
    }
        
    private let imageView = ImageResourceView()
    
    /// This token is changes everytime the cell is re-used. Useful when performing
    /// asynchronous tasks where the cell might have been re-used in the mean time.
    private var reuseToken = UUID()

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadView()
    }
    
    var isHeightCalculated: Bool = false
    
    func loadView() {
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.imageView.accessibilityIdentifier = "image"
        self.imageView.imageSizeLimit = .maxDimensionForShortSide(CollectionImageCell.maxCellSize * UIScreen.main.scale)
        self.secureContentsView.addSubview(self.imageView)
        constrain(self, self.imageView) { selfView, imageView in
            imageView.left == selfView.left
            imageView.right == selfView.right
            imageView.top == selfView.top
            imageView.bottom == selfView.bottom
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.message = .none
        self.isHeightCalculated = false
        self.reuseToken = UUID()
    }

    override var obfuscationIcon: StyleKitIcon {
        return .photo
    }
    
    override func updateForMessage(changeInfo: MessageChangeInfo?) {
        super.updateForMessage(changeInfo: changeInfo)
        
        guard let changeInfo = changeInfo, changeInfo.imageChanged else { return }
        
        loadImage()
    }

    var saveableImage : SavableImage?
    
    @objc func save(_ sender: AnyObject!) {
        guard let imageMessageData = self.message?.imageMessageData, let imageData = imageMessageData.imageData else { return }
        
        saveableImage = SavableImage(data: imageData, isGIF: imageMessageData.isAnimatedGIF)
        saveableImage?.saveToLibrary { [weak self] _ in
            self?.saveableImage = nil
        }
    }

    fileprivate func loadImage() {
        imageView.imageResource = message?.imageMessageData?.image
    }
}

