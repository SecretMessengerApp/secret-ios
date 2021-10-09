
import Foundation
import Cartography

final class VerificationCodeFieldDescription: NSObject, ValueSubmission {
    var valueSubmitted: ValueSubmitted?
    var valueValidated: ValueValidated?
    var acceptsInput: Bool = true
    var constraints: [NSLayoutConstraint] = []
}

fileprivate final class ResponderContainer<Child: UIView>: UIView {
    private let responder: Child
    
    init(responder: Child) {
        self.responder = responder
        super.init(frame: .zero)
        self.addSubview(self.responder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var canBecomeFirstResponder: Bool {
        return self.responder.canBecomeFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        return self.responder.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return self.responder.resignFirstResponder()
    }
}

extension ResponderContainer: TextContainer where Child: TextContainer {

    var text: String? {
        get {
            return responder.text
        }
        set {
            responder.text = newValue
        }
    }

}

extension VerificationCodeFieldDescription: ViewDescriptor {
    func create() -> UIView {
        /// get the with from keyWindow for iPad non full screen modes.
        let width = UIApplication.shared.keyWindow?.frame.width ?? UIScreen.main.bounds.size.width
        let size = CGSize(width: width, height: AuthenticationStepController.mainViewHeight)

        let inputField = CharacterInputField(maxLength: 6, characterSet: .decimalDigits, size: size)
        inputField.keyboardType = .decimalPad
        inputField.translatesAutoresizingMaskIntoConstraints = false
        inputField.delegate = self
        inputField.accessibilityIdentifier = "VerificationCode"
        inputField.accessibilityLabel = "verification.code_label".localized

        if #available(iOS 12, *) {
            inputField.textContentType = .oneTimeCode
        }

        let containerView = ResponderContainer(responder: inputField)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            inputField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            inputField.topAnchor.constraint(equalTo: containerView.topAnchor),
            inputField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            inputField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        
        return containerView
    }
}

extension VerificationCodeFieldDescription: CharacterInputFieldDelegate {

    func shouldAcceptChanges(_ inputField: CharacterInputField) -> Bool {
        return acceptsInput && inputField.text != nil
    }

    func didChangeText(_ inputField: CharacterInputField, to: String) {
        self.valueValidated?(.none)
    }

    func didFillInput(inputField: CharacterInputField, text: String) {
        self.valueSubmitted?(text)
    }
}
