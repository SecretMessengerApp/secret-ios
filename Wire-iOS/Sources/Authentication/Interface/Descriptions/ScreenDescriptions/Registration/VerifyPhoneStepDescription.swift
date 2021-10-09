
import Foundation

class VerifyPhoneStepSecondaryView: AuthenticationSecondaryViewDescription {
    let views: [ViewDescriptor]
    weak var actioner: AuthenticationActioner?

    init(phoneNumber: String, allowChange: Bool) {
        let resendCode = ButtonDescription(title: "team.activation_code.button.resend".localized, accessibilityIdentifier: "resend_button")
        let changePhoneNumber = ButtonDescription(title: "team.activation_code.button.change_phone".localized, accessibilityIdentifier: "change_phone_button")
        views = allowChange ? [resendCode, changePhoneNumber] : [resendCode]

        resendCode.buttonTapped = { [weak self] in
            self?.actioner?.repeatAction()
        }

        changePhoneNumber.buttonTapped = { [weak self] in
            self?.actioner?.executeAction(.unwindState(withInterface: true))
        }
    }
}

final class VerifyPhoneStepDescription: AuthenticationStepDescription {
    let phoneNumber: String
    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?

    init(phoneNumber: String, allowChange: Bool) {
        self.phoneNumber = phoneNumber
        backButton = nil
        mainView = VerificationCodeFieldDescription()
        headline = "team.phone_activation_code.headline".localized
        subtext = "team.activation_code.subheadline".localized(args: phoneNumber)
        secondaryView = VerifyPhoneStepSecondaryView(phoneNumber: phoneNumber, allowChange: allowChange)
    }

    func shouldSkipFromNavigation() -> Bool {
        return true
    }
}
