
import Foundation

final class SetPasswordStepDescription: DefaultValidatingStepDescription {

    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?
    let initialValidation: ValueValidation

    init() {
        backButton = BackButtonDescription()
        let textField = TextFieldDescription(placeholder: "password.placeholder".localized, actionDescription: "general.next".localized, kind: .password(isNew: true))
        textField.useDeferredValidation = true
        mainView = textField
        headline = "team.password.headline".localized
        subtext = nil
        secondaryView = nil
        initialValidation = .info(PasswordRuleSet.localizedErrorMessage)
    }
}
