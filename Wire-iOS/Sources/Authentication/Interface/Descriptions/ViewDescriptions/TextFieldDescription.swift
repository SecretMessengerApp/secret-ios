
import Foundation

final class TextFieldDescription: NSObject, ValueSubmission {
    let placeholder: String
    let actionDescription: String
    let kind: AccessoryTextField.Kind
    var valueSubmitted: ValueSubmitted?
    var valueValidated: ValueValidated?
    var acceptsInput: Bool = true
    var validationError: TextFieldValidator.ValidationError?
    let uppercasePlaceholder: Bool
    var showConfirmButton: Bool = true
    var canSubmit: (() -> Bool)?
    var textField: AccessoryTextField?
    var useDeferredValidation: Bool = false
    var editingChangedListener: ((String?) -> Void)?

    init(placeholder: String, actionDescription: String, kind: AccessoryTextField.Kind, uppercasePlaceholder: Bool = true) {
        self.placeholder = placeholder
        self.actionDescription = actionDescription
        self.uppercasePlaceholder = uppercasePlaceholder
        self.kind = kind
        validationError = .tooShort(kind: kind)
        super.init()

        canSubmit = { [weak self] in
            return (self?.acceptsInput == true) && (self?.validationError == nil)
        }
    }
}

extension TextFieldDescription: ViewDescriptor {
    func create() -> UIView {
        let textField = AccessoryTextField(kind: kind)
        textField.enablesReturnKeyAutomatically = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = uppercasePlaceholder ? self.placeholder.localizedUppercase : self.placeholder
        textField.delegate = self
        textField.textFieldValidationDelegate = self
        textField.confirmButton.addTarget(self, action: #selector(TextFieldDescription.confirmButtonTapped(_:)), for: .touchUpInside)
        textField.addTarget(self, action: #selector(TextFieldDescription.editingChanged), for: .editingChanged)
        textField.confirmButton.accessibilityLabel = self.actionDescription
        textField.showConfirmButton = showConfirmButton

        textField.enableConfirmButton = { [weak self] in
            if self?.useDeferredValidation == true {
                return !textField.input.isEmpty
            } else {
                return self?.canSubmit?() == true
            }
        }

        self.textField = textField
        return textField
    }
}

extension TextFieldDescription: UITextFieldDelegate {

    @objc func confirmButtonTapped(_ sender: AnyObject) {
        guard let textField = self.textField, acceptsInput else { return }
        submitValue(with: textField.input)
    }

    @objc func editingChanged(sender: AccessoryTextField) {
        self.editingChangedListener?(sender.text)
        // If we use deferred validation, remove the error when the text changes
        guard useDeferredValidation else { return }
        self.valueValidated?(nil)
        sender.hideGuidanceDot()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return acceptsInput
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let textField = self.textField, acceptsInput else { return false }

        textField.validateInput()

        if validationError == .none || useDeferredValidation {
            submitValue(with: textField.input)
            return true
        } else {
           return false
        }
    }

    func submitValue(with text: String) {
        if let error = validationError {
            textField?.showGuidanceDot()
            self.valueValidated?(.error(error, showVisualFeedback: textField?.input.isEmpty == false))
        } else {
            self.valueValidated?(nil)
            self.valueSubmitted?(text)
        }
    }
}

extension TextFieldDescription: TextFieldValidationDelegate {
    func validationUpdated(sender: UITextField, error: TextFieldValidator.ValidationError?) {
        self.validationError = error
    }
}

