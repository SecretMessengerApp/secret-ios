
import Foundation
import Cartography

final class CollectionHeaderView: UICollectionReusableView {
    
    var section: CollectionsSectionSet = .none {
        didSet {
            let icon: StyleKitIcon
            
            switch(section) {
            case CollectionsSectionSet.images:
                self.titleLabel.text = "collections.section.images.title".localized(uppercased: true)
                icon = .photo
            case CollectionsSectionSet.filesAndAudio:
                self.titleLabel.text = "collections.section.files.title".localized(uppercased: true)
                icon = .document
            case CollectionsSectionSet.videos:
                self.titleLabel.text = "collections.section.videos.title".localized(uppercased: true)
                icon = .movie
            case CollectionsSectionSet.links:
                self.titleLabel.text = "collections.section.links.title".localized(uppercased: true)
                icon = .link
            default: fatal("Unknown section")
            }
            
            self.iconImageView.setIcon(icon, size: .tiny, color: .lightGraphite)
        }
    }
    
    var totalItemsCount: UInt = 0 {
        didSet {
            self.actionButton.isHidden = totalItemsCount == 0
            
            let totalCountText = String(format: "collections.section.all.button".localized, totalItemsCount)
            self.actionButton.setTitle(totalCountText, for: .normal)
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .smallSemiboldFont
        label.textColor = .dynamic(scheme: .title)
        return label
    }()

    let actionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.strongBlue, for: .normal)
        button.titleLabel?.font = .smallSemiboldFont

        return button
    }()

    let iconImageView = UIImageView()
    
    var selectionAction: ((CollectionsSectionSet) -> ())? = .none
    
    required init(coder: NSCoder) {
        fatal("init(coder: NSCoder) is not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.titleLabel)
        
        self.actionButton.contentHorizontalAlignment = .right
        self.actionButton.accessibilityLabel = "open all"
        self.actionButton.addTarget(self, action: #selector(CollectionHeaderView.didSelect(_:)), for: .touchUpInside)
        self.addSubview(self.actionButton)
        
        self.iconImageView.contentMode = .center
        self.addSubview(self.iconImageView)
        
        constrain(self, self.titleLabel, self.actionButton, self.iconImageView) { selfView, titleLabel, actionButton, iconImageView in
            iconImageView.leading == selfView.leading + 16
            iconImageView.centerY == selfView.centerY
            iconImageView.width == 16
            iconImageView.height == 16
            
            titleLabel.leading == iconImageView.trailing + 8
            titleLabel.centerY == selfView.centerY
            titleLabel.trailing == selfView.trailing
            
            actionButton.leading == selfView.leading
            actionButton.top == selfView.top
            actionButton.trailing == selfView.trailing - 16
            actionButton.bottom == selfView.bottom
        }
    }
    
    public var desiredWidth: CGFloat = 0
    public var desiredHeight: CGFloat = 0
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: self.desiredWidth, height: self.desiredHeight)
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        var newFrame = layoutAttributes.frame
        newFrame.size.width = intrinsicContentSize.width
        newFrame.size.height = intrinsicContentSize.height
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
    
    @objc func didSelect(_ button: UIButton!) {
        self.selectionAction?(self.section)
    }
}
