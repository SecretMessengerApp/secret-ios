
final class SecretSetPasswordStepDescription: DefaultValidatingStepDescription {
    
    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?
    let initialValidation: ValueValidation
    let isShowKeyBoard: Bool = false
    
    init() {
        backButton = BackButtonDescription()
        let textField = TextFieldDescription(placeholder: "register.email.setpassword.placeholder".localized, actionDescription: "general.next".localized, kind: .password(isNew: true))
        mainView = textField
        headline = "register.email.setpassword.title".localized
        subtext = nil
        secondaryView = nil
        initialValidation = .info(PasswordRuleSet.localizedErrorMessage)
    }
}
