
import UIKit
import WireCommonComponents
import WireShareEngine

class ConversationStateAccessoryView: UIView {

    private let contentStack = UIStackView()
    private let legalHoldImageView = UIImageView()
    private let verifiedImageView = UIImageView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
        configureConstraints()
    }

    private func configureSubviews() {
        contentStack.axis = .horizontal
        contentStack.distribution = .fillEqually
        contentStack.alignment = .fill
        contentStack.spacing = 8

        legalHoldImageView.setContentHuggingPriority(.required, for: .horizontal)
        //todo fix
//        legalHoldImageView.setIcon(.cameraLens, size: 16, color: .)
        contentStack.addArrangedSubview(legalHoldImageView)

        verifiedImageView.setContentHuggingPriority(.required, for: .horizontal)
        contentStack.addArrangedSubview(verifiedImageView)

        addSubview(contentStack)
    }

    private func configureConstraints() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.setContentHuggingPriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Configuration

    func prepareForReuse() {
        legalHoldImageView.isHidden = true
        verifiedImageView.isHidden = true
        verifiedImageView.image = nil
    }

    func configure(for conversation: Conversation) {
        legalHoldImageView.isHidden = !conversation.legalHoldStatus.denotesEnabledComplianceDevice

        if let verificationImage = iconForVerificationLevel(in: conversation) {
            verifiedImageView.image = verificationImage
            verifiedImageView.isHidden = false
        } else {
            verifiedImageView.isHidden = true
            verifiedImageView.image = nil
        }
    }

    private func iconForVerificationLevel(in conversation: Conversation) -> UIImage? {
        switch conversation.securityLevel {
        case .secure:
            return WireStyleKit.imageOfShieldverified
        case .secureWithIgnored:
            return WireStyleKit.imageOfShieldnotverified
        case .notSecure:
            return nil
        }
    }

}
