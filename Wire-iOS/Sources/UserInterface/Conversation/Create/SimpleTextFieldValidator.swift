//
import Foundation
import WireUtilities

protocol SimpleTextFieldValidatorDelegate: class {
    func textFieldValueChanged(_ value: String?)
    func textFieldValueSubmitted(_ value: String)
    func textFieldDidEndEditing()
    func textFieldDidBeginEditing()
}

final class SimpleTextFieldValidator: NSObject {

    weak var delegate: SimpleTextFieldValidatorDelegate?

    enum ValidationError {
        case empty
        case tooLong
    }

    func validate(text: String) -> SimpleTextFieldValidator.ValidationError? {
        let stringToValidate = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if stringToValidate.isEmpty {
            return .empty
        }
        
        var validatedString: Any? = stringToValidate as Any
        
        do {
            _ = try StringLengthValidator.validateStringValue(&validatedString,
                                                    minimumStringLength: 1,
                                                    maximumStringLength: 64,
                                                    maximumByteLength: 256)
        }
        catch let stringValidationError as NSError {
            
            switch stringValidationError.code {
            case Int(ZMManagedObjectValidationErrorCode.tooLong.rawValue):
                return .tooLong
            default: break
            }
        }
    
        return nil
    }
}

extension SimpleTextFieldValidator: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldValue = textField.text as NSString?
        let result = oldValue?.replacingCharacters(in: range, with: string) ?? ""
        if !result.isEmpty, let _ = self.validate(text: result)  {
            return false
        }
        delegate?.textFieldValueChanged(result)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return true }
        delegate?.textFieldValueSubmitted(text)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldDidEndEditing()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing()
    }
    
}

extension SimpleTextFieldValidator.ValidationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .tooLong:
            return "conversation.create.guidance.toolong".localized
        case .empty:
            return "conversation.create.guidance.empty".localized
        }
    }
}
