

import Foundation
import Cartography

final class CollectionCellHeader: UIView {
    var message: ZMConversationMessage? {
        didSet {
            guard let message = self.message, let serverTimestamp = message.serverTimestamp, let sender = message.sender else {
                return
            }
            
            self.nameLabel.textColor = sender.nameAccentColor
            self.nameLabel.text = sender.displayName
            self.dateLabel.text = serverTimestamp.formattedDate
        }
    }
    
    required init(coder: NSCoder) {
        fatal("init(coder: NSCoder) is not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.nameLabel)
        self.addSubview(self.dateLabel)
        
        constrain(self, self.nameLabel, self.dateLabel) { selfView, nameLabel, dateLabel in
            nameLabel.leading == selfView.leading
            nameLabel.trailing <= dateLabel.leading
            dateLabel.trailing == selfView.trailing
            nameLabel.top == selfView.top
            nameLabel.bottom == selfView.bottom
            dateLabel.centerY == nameLabel.centerY
        }
    }
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.accessibilityLabel = "sender name"
        label.font = .smallSemiboldFont

        return label
    }()

    var dateLabel: UILabel = {
        let label = UILabel()
        label.accessibilityLabel = "sent on"
        label.font = .smallLightFont
        label.textColor = .from(scheme: .textDimmed)

        return label
    }()
}
