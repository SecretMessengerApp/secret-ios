//

import Foundation
import Cartography

 final class NoResultsView: UIView {
    let label = UILabel()
    private let iconView = UIImageView()

    var placeholderText: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
            label.accessibilityLabel = newValue
        }
    }
    
    var icon: StyleKitIcon? = nil {
        didSet {
            self.iconView.image = icon?.makeImage(size: 160, color: placeholderColor)
        }
    }
    
    var placeholderColor: UIColor {
        .dynamic(scheme: .placeholder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.accessibilityElements = [self.label]
        
        self.label.numberOfLines = 0
        self.label.textColor = placeholderColor
        self.label.textAlignment = .center
        label.font = .mediumSemiboldFont
        self.addSubview(self.label)
        
        self.iconView.contentMode = .scaleAspectFit
        self.addSubview(self.iconView)
        
        constrain(self, self.label, self.iconView) { selfView, label, iconView in
            iconView.top == selfView.top
            iconView.centerX == selfView.centerX
            
            label.top == iconView.bottom + 24
            label.bottom == selfView.bottom
            label.leading == selfView.leading
            label.trailing == selfView.trailing
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatal("init?(coder:) is not implemented")
    }
}
