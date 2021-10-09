
final class SecretLoginPasswordStepDescription: AuthenticationStepDescription {
    
    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?
    let isShowKeyBoard: Bool = false
    
    init() {
        backButton = BackButtonDescription()
        let description = TextFieldDescription(placeholder: "login.email.password.placeholder".localized, actionDescription: "general.next".localized, kind: .password(isNew: false))
        mainView = description
        headline = "login.email.password.title".localized
        subtext = nil
        secondaryView = SecretLoginPasswordStepSecondaryView()
    }
}
