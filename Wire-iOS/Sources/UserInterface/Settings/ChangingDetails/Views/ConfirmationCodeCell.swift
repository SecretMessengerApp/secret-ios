
import Foundation

class ConfirmationCodeCell: UITableViewCell {

    let textField: CharacterInputField = {
        let textField = CharacterInputField(maxLength: 6, characterSet: .decimalDigits, size: CGSize(width: 375, height: 56))
        return textField
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
        createConstraints()

        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(textField)

        if #available(iOS 12, *) {
            textField.textContentType = .oneTimeCode
        }

        textField.keyboardType = .decimalPad
        textField.accessibilityIdentifier = "VerificationCode"
        textField.accessibilityLabel = "verification.code_label".localized
        textField.isAccessibilityElement = true
    }

    private func createConstraints() {
        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8)
        ])
    }

}
