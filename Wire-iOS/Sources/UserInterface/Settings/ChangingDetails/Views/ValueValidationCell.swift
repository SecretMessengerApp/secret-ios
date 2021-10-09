
import UIKit

/**
 * A cell to show a value validation in the settings.
 */

class ValueValidationCell: UITableViewCell {

    let label: UILabel = {
        let label = UILabel()
        label.font = AuthenticationStepController.errorMessageFont
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    /// The initial validation to use.
    let initialValidation: ValueValidation

    // MARK: - Initialization

    /// Creates the cell with the default validation to display.
    init(initialValidation: ValueValidation) {
        self.initialValidation = initialValidation
        super.init(style: .default, reuseIdentifier: nil)
        setupViews()
        createConstraints()
        updateValidation(initialValidation)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(label)
    }

    private func createConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(24 + AccessoryTextField.ConfirmButtonWidth)),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
        ])
    }

    // MARK: - Content

    /// Updates the label for the displayed validation.
    func updateValidation(_ validation: ValueValidation?) {
        switch validation {
        case .info(let infoText)?:
            label.accessibilityIdentifier = "validation-rules"
            label.text = infoText
            label.textColor = UIColor.Team.placeholderColor

        case .error(let error, let showVisualFeedback)?:
            if !showVisualFeedback {
                // If we do not want to show an error (eg if all the text was deleted,
                // use the initial info
                return updateValidation(initialValidation)
            }

            label.accessibilityIdentifier = "validation-failure"
            label.text = error.errorDescription
            label.textColor = UIColor.from(scheme: .errorIndicator, variant: .dark)

        case nil:
            updateValidation(initialValidation)
        }
    }

}
