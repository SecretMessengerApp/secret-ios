
import Foundation

class VerifyEmailStepSecondaryView: AuthenticationSecondaryViewDescription {
    let views: [ViewDescriptor]
    weak var actioner: AuthenticationActioner?

    init(canResend: Bool = true) {
        let resendCode = ButtonDescription(title: "team.activation_code.button.resend".localized, accessibilityIdentifier: "resend_button")
        let changeEmail = ButtonDescription(title: "team.activation_code.button.change_email".localized, accessibilityIdentifier: "change_email_button")

        if canResend {
            views = [resendCode, changeEmail]
        } else {
            views = [changeEmail]
        }

        resendCode.buttonTapped = { [weak self] in
            self?.actioner?.repeatAction()
        }

        changeEmail.buttonTapped = { [weak self] in
            self?.actioner?.executeAction(.unwindState(withInterface: true))
        }
    }
}

final class VerifyEmailStepDescription: AuthenticationStepDescription {
    let email: String
    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?

    init(email: String) {
        self.email = email
        backButton = nil
        mainView = VerificationCodeFieldDescription()
        headline = "team.activation_code.headline".localized
        subtext = "team.activation_code.subheadline".localized(args: email)
        secondaryView = VerifyEmailStepSecondaryView()
    }

    func shouldSkipFromNavigation() -> Bool {
        return true
    }
}
