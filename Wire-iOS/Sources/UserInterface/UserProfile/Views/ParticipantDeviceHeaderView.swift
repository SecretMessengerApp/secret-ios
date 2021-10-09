
import Foundation
import UIKit

protocol ParticipantDeviceHeaderViewDelegate: class {
    func participantsDeviceHeaderViewDidTapLearnMore(_ headerView: ParticipantDeviceHeaderView)
}

final class ParticipantDeviceHeaderView: UIView {
    private var font: UIFont = .normalLightFont
    private var textColor: UIColor = .dynamic(scheme: .title)
    private var linkAttributeColor: UIColor = .accent()
    private var textView: WebLinkTextView = WebLinkTextView()
    let userName: String

    weak var delegate: ParticipantDeviceHeaderViewDelegate?
    var showUnencryptedLabel = false {
        didSet {
            textView.attributedText = attributedExplanationText(for: userName, showUnencryptedLabel: showUnencryptedLabel)
        }
    }

    init(userName: String) {
        self.userName = userName

        super.init(frame: CGRect.zero)

        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        backgroundColor = .clear
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        textView.textContainer.maximumNumberOfLines = 0
        textView.delegate = self
        textView.linkTextAttributes = [:]

        addSubview(textView)
    }

    // MARK: Attributed Text

    func attributedExplanationText(for userName: String,
                                   showUnencryptedLabel unencrypted: Bool) -> NSAttributedString? {
        if unencrypted {
            let message = "profile.devices.fingerprint_message_unencrypted".localized
            return attributedFingerprint(forUserName: userName, message: message)
        } else {
            let message = "\("profile.devices.fingerprint_message.title".localized)\("general.space_between_words".localized)"

            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedFingerprint(forUserName: userName, message: message))
            

//            let fingerprintLearnMoreLink = "profile.devices.fingerprint_message.link".localized && linkAttributes

            return mutableAttributedString/* + fingerprintLearnMoreLink*/
        }
    }

    func attributedFingerprint(forUserName userName: String, message: String) -> NSAttributedString {
        let fingerprintExplanation = String(format: message, userName)

        let textAttributes = [
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.paragraphStyle: paragraphStyleForFingerprint
        ]

        return NSAttributedString(string: fingerprintExplanation, attributes: textAttributes)
    }

    var linkAttributes: [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: linkAttributeColor,
            NSAttributedString.Key.link: NSURL.wr_fingerprintLearnMoreURL,
            NSAttributedString.Key.paragraphStyle: paragraphStyleForFingerprint
        ]
    }

    var paragraphStyleForFingerprint: NSMutableParagraphStyle {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineSpacing = 2

        return paragraphStyle
    }

    private func setupConstraints() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.fitInSuperview(with: EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
    }

}

extension ParticipantDeviceHeaderView: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        delegate?.participantsDeviceHeaderViewDidTapLearnMore(self)

        return false
    }
}
