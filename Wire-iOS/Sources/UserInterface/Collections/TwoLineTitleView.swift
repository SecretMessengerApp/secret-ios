

import UIKit
import Cartography

public final class TwoLineTitleView: UIView {
    
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .smallSemiboldFont
        label.textColor = .dynamic(scheme: .title)

        return label
    }()

    public let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .smallLightFont
        label.textColor = .dynamic(scheme: .title)

        return label
    }()
    
    init(first: String, second: String) {
        super.init(frame: CGRect.zero)
        self.isAccessibilityElement = true
        
        self.titleLabel.textAlignment = .center
        self.subtitleLabel.textAlignment = .center
        
        self.titleLabel.text = first
        self.subtitleLabel.text = second
        
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
        
        translatesAutoresizingMaskIntoConstraints = false
        constrain(self, self.titleLabel, self.subtitleLabel) { selfView, titleLabel, subtitleLabel in
            titleLabel.leading == selfView.leading
            titleLabel.trailing == selfView.trailing
            titleLabel.top == selfView.top + 4
            subtitleLabel.top == titleLabel.bottom
            subtitleLabel.leading == selfView.leading
            subtitleLabel.trailing == selfView.trailing
            subtitleLabel.bottom == selfView.bottom
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

