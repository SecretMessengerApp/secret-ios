
final class SecretSetFullNameStepDescription: AuthenticationStepDescription {
    
    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?
    let isShowKeyBoard: Bool = false
    
    init() {
        backButton = BackButtonDescription()
        mainView = TextFieldDescription(placeholder: "register.email.setname.placeholder".localized, actionDescription: "general.next".localized, kind: .name(isTeam: false))
        headline = "register.email.setname.title".localized
        subtext = nil
        secondaryView = nil
    }
}
