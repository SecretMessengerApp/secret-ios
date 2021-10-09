//
// Wire
// Copyright (C) 2017 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import UIKit
import Cartography

final class TeamInviteTextFieldFooterView: UIView {
    
    private let textFieldDescriptor = TextFieldDescription(
        placeholder: "team.invite.textfield.placeholder".localized,
        actionDescription: "team.invite.textfield.accesibility".localized,
        kind: .email,
        uppercasePlaceholder: false
    )
    
    var isLoading = false {
        didSet {
            updateLoadingState()
        }
    }
    
    let errorButton = Button()
    private let textField: AccessoryTextField
    private let errorLabel = UILabel()

    var shouldConfirm: ((String) -> Bool)? {
        didSet {
            textField.textFieldValidator.customValidator = { [weak self] email in
                (self?.shouldConfirm?(email) ?? true) ? nil : .custom("team.invite.error.already_invited".localized.uppercased())
            }
        }
    }
    
    var onConfirm: ((String) -> Void)? {
        didSet {
            textFieldDescriptor.valueSubmitted = onConfirm
        }
    }
    
    var errorMessage: String? {
        didSet {
            errorLabel.text = errorMessage
        }
    }
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    init() {
        textField = textFieldDescriptor.create() as! AccessoryTextField
        super.init(frame: .zero)
        setupViews()
        createConstraints()
        isAccessibilityElement = false
        accessibilityElements = [textField, errorLabel, errorButton]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        errorButton.isHidden = true
        errorLabel.textAlignment = .center
        errorLabel.font = TeamCreationStepController.errorFont
        errorLabel.textColor = UIColor.Team.errorMessageColor
        textField.overrideButtonIcon = .send
        textFieldDescriptor.valueValidated = { [weak self] error in
            self?.errorMessage = error.errorDescription?.uppercased()
            if error == .none {
                self?.errorButton.isHidden = true
            }
        }

        errorButton.setTitle("team.invite.learn_more.title".localized.uppercased(), for: .normal)
        errorButton.titleLabel?.font = FontSpec(.medium, .semibold).font!
        errorButton.setTitleColor(.black, for: .normal)
        errorButton.setTitleColor(.darkGray, for: .highlighted)
        errorButton.accessibilityIdentifier = "LearnMoreButton"
        errorButton.addTarget(self, action: #selector(showLearnMorePage), for: .touchUpInside)
        textField.accessibilityLabel = "EmailInputField"
        [textField, errorLabel, errorButton].forEach(addSubview)
        backgroundColor = .clear
    }
    
    private func createConstraints() {
        constrain(self, textField, errorLabel, errorButton) { view, textField, errorLabel, errorButton in
            textField.leading == view.leading
            textField.trailing == view.trailing
            textField.top == view.top + 4
            textField.height == 56
            errorLabel.centerX == view.centerX
            errorLabel.top == textField.bottom + 8
            errorLabel.height == 20

            errorButton.centerX == view.centerX
            errorButton.top == errorLabel.bottom + 24
            errorButton.bottom == view.bottom - 12
        }
    }
    
    func clearInput() {
        textField.text = ""
        textField.textFieldDidChange(textField: textField)
    }
    
    @objc private func showLearnMorePage() {
        let url = URL(string: "https://support.secret.im/hc/en-us/articles/115004082129-My-email-address-is-already-in-use-and-I-cannot-create-an-account-What-can-I-do-")!
        UIApplication.shared.open(url)
    }
    
    private func updateLoadingState() {
        textField.isLoading = isLoading
        textFieldDescriptor.acceptsInput = !isLoading
    }
}
