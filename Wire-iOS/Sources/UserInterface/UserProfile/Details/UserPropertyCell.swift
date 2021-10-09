
import UIKit

/**
 * A cell that displays a user property as part of the rich profile data.
 */

class UserPropertyCell: SeparatorTableViewCell {
    
    private let contentStack = UIStackView()

    private let propertyNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.font = .smallRegularFont
        return label
    }()
    
    private let propertyValueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.font = .normalLightFont
        return label
    }()
    
    // MARK: - Contents
    
    /// The name of the user property.
    var propertyName: String? {
        get {
            return propertyNameLabel.text
        }
        set {
            propertyNameLabel.text = newValue
            accessibilityIdentifier = "InformationKey" + (newValue ?? "None")
            accessibilityLabel = newValue
        }
    }
    
    /// The value of the user property.
    var propertyValue: String? {
        get {
            return propertyValueLabel.text
        }
        set {
            propertyValueLabel.text = newValue
            accessibilityValue = newValue
        }
    }
    
    // MARK: - Initialization

    override func setUp() {
        super.setUp()
        configureSubviews()
        configureConstraints()
    }
        
    private func configureSubviews() {
        contentStack.addArrangedSubview(propertyNameLabel)
        contentStack.addArrangedSubview(propertyValueLabel)
        contentStack.spacing = 2
        contentStack.axis = .vertical
        contentStack.distribution = .equalSpacing
        contentStack.alignment = .leading
        contentView.addSubview(contentStack)
        
        applyColorScheme(colorSchemeVariant)
        shouldGroupAccessibilityChildren = true
    }
    
    private func configureConstraints() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    
    override func applyColorScheme(_ variant: ColorSchemeVariant) {
        super.applyColorScheme(variant)
        propertyNameLabel.textColor = UIColor.from(scheme: .textDimmed, variant: variant)
        propertyValueLabel.textColor = UIColor.dynamic(scheme: .title)
        backgroundColor = UIColor.from(scheme: .background, variant: variant)
    }
    
}
