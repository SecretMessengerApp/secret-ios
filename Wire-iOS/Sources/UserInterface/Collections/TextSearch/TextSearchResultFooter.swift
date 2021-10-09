

import Foundation
import Cartography


public final class TextSearchResultFooter: UIView {
    public var message: ZMConversationMessage? {
        didSet {
            guard let message = self.message, let serverTimestamp = message.serverTimestamp, let sender = message.sender else {
                return
            }
            
            self.nameLabel.textColor = sender.nameAccentColor
            self.nameLabel.text = sender.displayName
            self.nameLabel.accessibilityValue = self.nameLabel.text
            
            self.dateLabel.text = serverTimestamp.formattedDate
            self.dateLabel.accessibilityValue = self.dateLabel.text
        }
    }
    
    public required init(coder: NSCoder) {
        fatal("init(coder: NSCoder) is not implemented")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.nameLabel.accessibilityLabel = "sender name"
        self.dateLabel.accessibilityLabel = "sent on"
        
        self.addSubview(self.nameLabel)
        self.addSubview(self.dateLabel)
        
        constrain(self, self.nameLabel, self.dateLabel) { selfView, nameLabel, dateLabel in
            nameLabel.leading == selfView.leading
            nameLabel.trailing == dateLabel.leading - 4
            dateLabel.trailing <= selfView.trailing
            nameLabel.top == selfView.top
            nameLabel.bottom == selfView.bottom
            dateLabel.centerY == nameLabel.centerY
        }
    }
    
    public var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .smallSemiboldFont

        return label
    }()

    public var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .smallLightFont
        label.textColor = .from(scheme: .textDimmed)

        return label
    }()
}
