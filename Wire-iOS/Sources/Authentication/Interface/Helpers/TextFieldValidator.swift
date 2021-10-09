
import Foundation
import WireUtilities

class TextFieldValidator {
    
    var customValidator: ((String) -> ValidationError?)?

    enum ValidationError: Error, Equatable {
        case tooShort(kind: AccessoryTextField.Kind)
        case tooLong(kind: AccessoryTextField.Kind)
        case invalidEmail
        case invalidPhoneNumber
        case invalidPassword(PasswordValidationResult)
        case custom(String)
    }

    func validate(text: String?, kind: AccessoryTextField.Kind) -> TextFieldValidator.ValidationError? {
        guard let text = text else {
            return nil
        }
        
        if let customError = customValidator?(text) {
            return customError
        }

        switch kind {
        case .email:
            if text.count > 254 {
                return .tooLong(kind: kind)
            } else if !text.isEmail {
                return .invalidEmail
            }
        case .password(let isNew):
            if isNew {
                // If the user is registering, enforce the password rules
                let result = PasswordRuleSet.shared.validatePassword(text)
                return result != .valid ? .invalidPassword(result) : nil
            } else {
                // If the user is signing in, we do not require any format
                return text.isEmpty ? .tooShort(kind: kind) : nil
            }

        case .name:
            /// We should ignore leading/trailing whitespace when counting the number of characters in the string
            let stringToValidate = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if stringToValidate.count > 64 {
                return .tooLong(kind: kind)
            } else if stringToValidate.count < 2 {
                return .tooShort(kind: kind)
            }
        case .phoneNumber, .unknown:
            // phone number is validated with the custom validator
            break
        }

        return .none

    }
}

extension TextFieldValidator {

    @available(iOS 12, *)
    var passwordRules: UITextInputPasswordRules {
        return UITextInputPasswordRules(descriptor: PasswordRuleSet.shared.encodeInKeychainFormat())
    }

}

extension TextFieldValidator.ValidationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .tooShort(kind: let kind):
            switch kind {
            case .name:
                return "name.guidance.tooshort".localized
            case .email:
                return "email.guidance.tooshort".localized
            case .password:
                return PasswordRuleSet.localizedErrorMessage
            case .unknown:
                return "unknown.guidance.tooshort".localized
            case .phoneNumber:
                return "phone.guidance.tooshort".localized
            }
        case .tooLong(kind: let kind):
            switch kind {
            case .name:
                return "name.guidance.toolong".localized
            case .email:
                return "email.guidance.toolong".localized
            case .password:
                return "password.guidance.toolong".localized
            case .unknown:
                return "unknown.guidance.toolong".localized
            case .phoneNumber:
                return "phone.guidance.toolong".localized
            }
        case .invalidEmail:
            return "email.guidance.invalid".localized
        case .invalidPhoneNumber:
            return "phone.guidance.invalid".localized
        case .custom(let description):
            return description
        case .invalidPassword(let error):
            switch error {
            case .tooLong:
                return "password.guidance.toolong".localized
            default:
                return PasswordRuleSet.localizedErrorMessage
            }

        }
    }

}

// MARK: - Email validator

extension String {
    public var isEmail: Bool {
        guard !self.hasPrefix("mailto:") else { return false }

        guard let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return false }

        let stringToMatch = self.trimmingCharacters(in: .whitespacesAndNewlines) // We should ignore leading/trailing whitespace
        let range = NSRange(location: 0, length: stringToMatch.count)
        let firstMatch = dataDetector.firstMatch(in: stringToMatch, options: NSRegularExpression.MatchingOptions.reportCompletion, range: range)

        let numberOfMatches = dataDetector.numberOfMatches(in: stringToMatch, options: NSRegularExpression.MatchingOptions.reportCompletion, range: range)

        if firstMatch?.range.location == NSNotFound { return false }
        if firstMatch?.url?.scheme != "mailto" { return false }
        if firstMatch?.url?.absoluteString.hasSuffix(stringToMatch) == false { return false }
        if numberOfMatches != 1 { return false }

        /// patch the NSDataDetector for its false-positive cases
        if self.contains("..") { return false }

        return true
    }
}
