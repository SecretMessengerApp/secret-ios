

final class SecretVerifyEmailStepDescription: AuthenticationStepDescription {
    
    let email: String
    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?
    
    let isShowKeyBoard: Bool = false
    
    init(email: String) {
        self.email = email
        backButton = nil
        mainView = VerifyCodeTextFieldDescription(placeholder: "register.email.verifycode.placeholder".localized, actionDescription: "general.next".localized, kind: .unknown)
        headline = "register.email.verifycode.title".localized
        subtext = nil
        secondaryView = VerifyEmailStepSecondaryView()
    }
    
    func shouldSkipFromNavigation() -> Bool {
        return true
    }
}
