
import Foundation
import WireUtilities
import FormatterKit

extension PasswordRuleSet {

    private static let arrayFormatter = TTTArrayFormatter()

    /// The shared rule set.
    static let shared: PasswordRuleSet = {
        let fileURL = Bundle.main.url(forResource: "password_rules", withExtension: "json")!
        let fileData = try! Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        return try! decoder.decode(PasswordRuleSet.self, from: fileData)
    }()

    // MARK: - Localized Description

    /// The localized error message for the shared rule set.
    static let localizedErrorMessage: String = {
        let ruleSet = PasswordRuleSet.shared
        let minLengthRule = "registration.password.rules.min_length".localized(args: ruleSet.minimumLength)

        if ruleSet.requiredCharacters.isEmpty {
            return "registration.password.rules.no_requirements".localized(args: minLengthRule)
        }

        let localizedRules: [String] = ruleSet.requiredCharacters.compactMap { requiredClass in
            switch requiredClass {
            case .digits:
                return "registration.password.rules.number".localized(args: 1)
            case .lowercase:
                return "registration.password.rules.lowercase".localized(args: 1)
            case .uppercase:
                return "registration.password.rules.uppercase".localized(args: 1)
            case .special:
                return "registration.password.rules.special".localized(args: 1)
            default:
                return nil
            }
        }

        let formattedRulesList = PasswordRuleSet.arrayFormatter.string(from: localizedRules)!
        return "registration.password.rules.with_requirements".localized(args: minLengthRule, formattedRulesList)
    }()

}
