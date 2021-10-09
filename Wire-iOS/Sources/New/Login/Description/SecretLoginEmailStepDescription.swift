
final class SecretLoginEmailStepDescription: AuthenticationStepDescription {
    
    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?
    let isShowKeyBoard: Bool = false
    
    init() {
        backButton = BackButtonDescription()
        mainView = TextFieldDescription(placeholder: "login.email.placeholder".localized, actionDescription: "general.next".localized, kind: .email)
        headline = "login.email.title".localized
        subtext = nil
        secondaryView = nil
    }
}
