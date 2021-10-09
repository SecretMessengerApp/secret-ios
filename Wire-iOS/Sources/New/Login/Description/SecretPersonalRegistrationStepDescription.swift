
/**
 * The step to start personal user registration.
 */

class SecretPersonalRegistrationStepDescription: AuthenticationStepDescription {
    
    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?
    
    var isShowKeyBoard: Bool = false
    
    init() {
        backButton = BackButtonDescription()
        let description = TextFieldDescription(placeholder: "login.email.placeholder".localized, actionDescription: "general.next".localized, kind: .email)
        mainView = description
        headline = "login.email.title".localized
        subtext = nil
        secondaryView = nil
    }
    
}
