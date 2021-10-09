
import UIKit

class PhoneNumberInputCell: UITableViewCell {

    let phoneInputView: PhoneNumberInputView = {
        let inputView = PhoneNumberInputView()
        inputView.showConfirmButton = false
        inputView.tintColor = .black
        return inputView
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
        contentView.addSubview(phoneInputView)
    }

    private func createConstraints() {
        phoneInputView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            phoneInputView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            phoneInputView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            phoneInputView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            phoneInputView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 8)
        ])
    }

}
