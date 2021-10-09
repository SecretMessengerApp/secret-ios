

import Foundation
import Cartography

public final class UserConnectionView: UIView, Copyable {
    
    public convenience init(instance: UserConnectionView) {
        self.init(user: instance.user)
    }

    static private var correlationFormatter: AddressBookCorrelationFormatter = {
        return AddressBookCorrelationFormatter(
            lightFont: FontSpec(.small, .light).font!,
            boldFont: FontSpec(.small, .medium).font!,
            color: UIColor.from(scheme: .textDimmed)
        )
    }()

    private let firstLabel = UILabel()
    private let secondLabel = UILabel()
    private let labelContainer = UIView()
    private let userImageView = UserImageView()
    private let encryptedLabel = EncryptedInfoLabel.create()
    
    public var user: UserType {
        didSet {
            self.updateLabels()
            self.userImageView.user = self.user
        }
    }
    
    public init(user: UserType) {
        self.user = user
        super.init(frame: .zero)
        self.userImageView.userSession = ZMUserSession.shared()
        self.setup()
        self.createConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        [firstLabel, secondLabel].forEach {
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }

        userImageView.accessibilityLabel = "user image"
        userImageView.size = .big
        userImageView.user = user
        
        [labelContainer, userImageView, encryptedLabel].forEach(addSubview)
        [firstLabel, secondLabel].forEach(labelContainer.addSubview)
        updateLabels()
    }

    private func updateLabels() {
        updateFirstLabel()
        updateSecondLabel()
        updateEncryptedLabel()
    }

    private func updateFirstLabel() {
        if let handleText = handleLabelText {
            firstLabel.attributedText = handleText
            firstLabel.accessibilityIdentifier = "username"
        } else {
            firstLabel.attributedText = correlationLabelText
            firstLabel.accessibilityIdentifier = "correlation"
        }
    }
    
    private func updateEncryptedLabel() {
        encryptedLabel.isHidden = !user.isConnected
    }

    private func updateSecondLabel() {
        guard nil != handleLabelText else { return }
        secondLabel.attributedText = correlationLabelText
        secondLabel.accessibilityIdentifier = "correlation"
    }

    private var handleLabelText: NSAttributedString? {
        guard let handle = user.handle, handle.count > 0 else { return nil }
        return ("@" + handle) && [
            .foregroundColor: UIColor.from(scheme: .textDimmed),
            .font: FontSpec(.small, .semibold).font!
        ]
    }

    private var correlationLabelText: NSAttributedString? {
        return type(of: self).correlationFormatter.correlationText(
            for: user,
            addressBookName: user.zmUser?.addressBookEntry?.cachedName
        )
    }
    
    private func createConstraints() {
        constrain(self, self.labelContainer, self.userImageView, encryptedLabel) { selfView, labelContainer, userImageView, encryptedLabel in
            labelContainer.centerX == selfView.centerX
            labelContainer.top == selfView.top
            labelContainer.left >= selfView.left

            userImageView.top >= labelContainer.bottom
            userImageView.center == selfView.center
            userImageView.left >= selfView.left + 54
            userImageView.width == userImageView.height
            userImageView.height <= 264
            
            encryptedLabel.left == selfView.left + 32
            encryptedLabel.right == selfView.right - 32
            encryptedLabel.bottom >= selfView.bottom - 32
        }

        let verticalMargin = CGFloat(16)

        constrain(labelContainer, firstLabel, secondLabel) { labelContainer, handleLabel, correlationLabel in
            handleLabel.top == labelContainer.top + verticalMargin
            handleLabel.height == 16
            correlationLabel.top == handleLabel.bottom
            handleLabel.height == 16
            correlationLabel.bottom == labelContainer.bottom - verticalMargin

            [handleLabel, correlationLabel].forEach {
                $0.leading == labelContainer.leading
                $0.trailing == labelContainer.trailing
            }
        }
    }

}

class EncryptedInfoLabel {
    
    static func create() -> ContentInsetLabel {
        let encryptedLabel = ContentInsetLabel()
        encryptedLabel.numberOfLines = 0
        encryptedLabel.contentInsets = .init(top: 8, left: 16, bottom: 8, right: 8)
        encryptedLabel.textColor = .dynamic(scheme: .title)
        encryptedLabel.font = .systemFont(ofSize: 12)
        encryptedLabel.accessibilityIdentifier = "encrypted message"
        encryptedLabel.backgroundColor = .dynamic(light: UIColor(hex: "#FFF4C0"), dark: UIColor(hex: "#2C2C2E"))
        encryptedLabel.layer.cornerRadius = 8
        encryptedLabel.layer.masksToBounds = true
        let text = "conversation.group.message.content.encrypted".localized
        let lockIcon = NSTextAttachment.textAttachment(
            for: .lockSVG,
            with: .dynamic(scheme: .title),
            iconSize: .tiny,
            verticalCorrection: -4
        )
        encryptedLabel.attributedText = NSAttributedString(attachment: lockIcon) + " " + text
        encryptedLabel.translatesAutoresizingMaskIntoConstraints = false
        return encryptedLabel
    }
}


class ContentInsetLabel: UILabel {
    
    var contentInsets: UIEdgeInsets = .zero

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += contentInsets.top + contentInsets.bottom
        contentSize.width += contentInsets.left + contentInsets.right
        return contentSize
    }
}
