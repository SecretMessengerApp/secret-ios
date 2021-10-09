
import Foundation

class AddEmailPasswordStepDescription: DefaultValidatingStepDescription {

    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?
    let initialValidation: ValueValidation

    init() {
        backButton = BackButtonDescription()
        mainView = EmailPasswordFieldDescription(forRegistration: true, usePasswordDeferredValidation: true)
        headline = "registration.add_email_password.hero.title".localized
        subtext = "registration.add_email_password.hero.paragraph".localized
        initialValidation = .info(PasswordRuleSet.localizedErrorMessage)
        secondaryView = nil
    }

}

