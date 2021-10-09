
import UIKit
import WireShareEngine

final class TargetConversationCell: UITableViewCell {

    let conversationNameLabel = UILabel()
    let stateAccessoryView = ConversationStateAccessoryView()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
        configureConstraints()
    }

    private func configureSubviews() {
        isAccessibilityElement = true
        shouldGroupAccessibilityChildren = true
        contentView.addSubview(stateAccessoryView)

        conversationNameLabel.font = .preferredFont(forTextStyle: .body)
        contentView.addSubview(conversationNameLabel)
    }

    private func configureConstraints() {
        conversationNameLabel.translatesAutoresizingMaskIntoConstraints = false
        stateAccessoryView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // stateAccessoryView
            stateAccessoryView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stateAccessoryView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            // conversationNameLabel
            conversationNameLabel.leadingAnchor.constraint(equalTo: stateAccessoryView.trailingAnchor, constant: 8),
            conversationNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            conversationNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor),
            conversationNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            conversationNameLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
        ])
    }

    // MARK: - Configuration

    override func prepareForReuse() {
        super.prepareForReuse()
        accessibilityLabel = nil
        conversationNameLabel.text = nil
        stateAccessoryView.prepareForReuse()
    }

    func configure(for conversation: Conversation) {
        // Subviews
        conversationNameLabel.text = conversation.name
        stateAccessoryView.configure(for: conversation)

        // Accessibility
        updateAccessibility(for: conversation)
    }

    private func updateAccessibility(for conversation: Conversation) {
        var details: [String] = []

        if conversation.legalHoldStatus.denotesEnabledComplianceDevice {
            details.append("share_extension.voiceover.conversation_under_legal_hold".localized)
        }

        switch conversation.securityLevel {
        case .notSecure:
            break
        case .secureWithIgnored:
            details.append("share_extension.voiceover.conversation_secure_with_ignored".localized)
        case .secure:
            details.append("share_extension.voiceover.conversation_secure".localized)
        }

        accessibilityLabel = conversation.name
        accessibilityValue = details.joined(separator: ", ")
    }

}
