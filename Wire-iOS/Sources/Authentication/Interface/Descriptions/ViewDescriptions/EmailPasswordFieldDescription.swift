
import UIKit

final class EmailPasswordFieldDescription: ValueSubmission {
    let textField = EmailPasswordTextField()

    var forRegistration: Bool
    var prefilledEmail: String?
    var usePasswordDeferredValidation: Bool
    var acceptsInput: Bool = true

    var valueSubmitted: ValueSubmitted?
    var valueValidated: ValueValidated?

    init(forRegistration: Bool, prefilledEmail: String? = nil, usePasswordDeferredValidation: Bool = false) {
        self.forRegistration = forRegistration
        self.usePasswordDeferredValidation = usePasswordDeferredValidation
    }

}

extension EmailPasswordFieldDescription: ViewDescriptor, EmailPasswordTextFieldDelegate {
    func create() -> UIView {
        textField.passwordField.kind = .password(isNew: forRegistration)
        textField.delegate = self
        textField.prefill(email: prefilledEmail)
        textField.emailField.validateInput()
        return textField
    }

    func textFieldDidUpdateText(_ textField: EmailPasswordTextField) {
        // Reset the error message when the user changes the text and we use deferred validation
        guard usePasswordDeferredValidation else { return }
        valueValidated?(nil)
        textField.passwordField.hideGuidanceDot()
    }

    func textField(_ textField: EmailPasswordTextField, didConfirmCredentials credentials: (String, String)) {
        valueSubmitted?(credentials)
    }

    func textFieldDidSubmitWithValidationError(_ textField: EmailPasswordTextField) {
        if let passwordError = textField.passwordValidationError {
            textField.passwordField.showGuidanceDot()
            valueValidated?(.error(passwordError, showVisualFeedback: true))
        }
    }
}
