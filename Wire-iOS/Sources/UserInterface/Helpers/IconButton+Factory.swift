
import UIKit

extension IconButton {
    
    static let width: CGFloat = 64
    static let height: CGFloat = 64

    
    static func acceptCall() -> IconButton {
        return .init(
            icon: .phone,
            accessibilityId: "AcceptButton",
            backgroundColor: [.normal: UIColor.strongLimeGreen],
            iconColor: [.normal: .white],
            width: IconButton.width
        )
    }
    
    static func endCall() -> IconButton {
        return .init(
            icon: .endCall,
            size: .small,
            accessibilityId: "LeaveCallButton",
            backgroundColor: [.normal: UIColor.vividRed],
            iconColor: [.normal: .white],
            width: IconButton.width
        )
    }

    static func sendButton() -> IconButton {

        let sendButtonIconColor = UIColor.from(scheme: .background, variant: .light)

        let sendButton = IconButton(
            icon: .send,
            accessibilityId: "sendButton",
            backgroundColor: [.normal:      UIColor.accent(),
                              .highlighted: UIColor.accentDarken],
            iconColor: [.normal: sendButtonIconColor,
                        .highlighted: sendButtonIconColor,
                        .disabled: sendButtonIconColor,
                        .selected: sendButtonIconColor]
        )

        sendButton.adjustsImageWhenHighlighted = false
        sendButton.adjustBackgroundImageWhenHighlighted = true

        return sendButton
    }

    fileprivate convenience init(
        icon: StyleKitIcon,
        size: StyleKitIcon.Size = .tiny,
        accessibilityId: String,
        backgroundColor: [UIControl.State: UIColor],
        iconColor: [UIControl.State: UIColor],
        width: CGFloat? = nil
        ) {
        self.init()
        circular = true
        setIcon(icon, size: size, for: .normal)
        titleLabel?.font = FontSpec(.small, .light).font!
        accessibilityIdentifier = accessibilityId
        translatesAutoresizingMaskIntoConstraints = false

        for (state, color) in backgroundColor {
            setBackgroundImageColor(color, for: state)
        }

        for (state, color) in iconColor {
            setIconColor(color, for: state)
        }

        borderWidth = 0

        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
            heightAnchor.constraint(greaterThanOrEqualToConstant: width).isActive = true
        }
    }
    
}

extension UIControl.State: Hashable {
    public var hashValue: Int {
        get {
            return Int(self.rawValue)
        }
    }
}
