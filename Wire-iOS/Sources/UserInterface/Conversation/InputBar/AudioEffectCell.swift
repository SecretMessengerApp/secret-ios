//


import Foundation
import Cartography
import avs

struct AudioEffectCellBorders : OptionSet {
    let rawValue: Int
    
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static let None   = AudioEffectCellBorders(rawValue: 0)
    static let Right  = AudioEffectCellBorders(rawValue: 1 << 0)
    static let Bottom = AudioEffectCellBorders(rawValue: 1 << 1)
}

final class AudioEffectCell: UICollectionViewCell {
    fileprivate let iconView = IconButton()
    fileprivate let borderRightView = UIView()
    fileprivate let borderBottomView = UIView()
    
    var borders: AudioEffectCellBorders = [.None] {
        didSet {
            self.updateBorders()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.clipsToBounds = false
        
        self.iconView.isUserInteractionEnabled = false
        [self.iconView, self.borderRightView, self.borderBottomView].forEach(self.contentView.addSubview)

        [self.borderRightView, self.borderBottomView].forEach { v in
            v.backgroundColor = UIColor(white: 1, alpha: 0.16)
        }
        
        constrain(self.contentView, self.iconView) { contentView, iconView in
            iconView.edges == contentView.edges
        }
        
        constrain(self.contentView, self.borderRightView, self.borderBottomView) { contentView, borderRightView, borderBottomView in

            borderRightView.bottom == contentView.bottom
            borderRightView.top == contentView.top
            borderRightView.right == contentView.right + 0.5
            borderRightView.width == .hairline
            
            borderBottomView.left == contentView.left
            borderBottomView.bottom == contentView.bottom + 0.5
            borderBottomView.right == contentView.right
            borderBottomView.height == .hairline
        }
        
        self.updateForSelectedState()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            self.updateForSelectedState()
        }
    }
    
    fileprivate func updateBorders() {
        self.borderRightView.isHidden = !self.borders.contains(.Right)
        self.borderBottomView.isHidden = !self.borders.contains(.Bottom)
    }
    
    fileprivate func updateForSelectedState() {
        let color: UIColor = self.isSelected ? UIColor.accent() : UIColor.white
        self.iconView.setIconColor(color, for: .normal)
    }
    
    var effect: AVSAudioEffectType = .none {
        didSet {
            self.iconView.setIcon(effect.icon, size: .small, for: .normal)
            self.accessibilityLabel = effect.description
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.effect = .none
        self.borders = .None
        self.updateForSelectedState()
    }
}
