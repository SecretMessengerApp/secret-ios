
import Foundation

/**
 * An object holding the configuration of the login prefill.
 */

struct AuthenticationPrefilledCredentials: Equatable {
    /// The primary type of credentials held in the value.
    let primaryCredentialsType: AuthenticationCredentialsType

    /// The raw credentials value.
    let credentials: LoginCredentials
    
    /// Whether the credentials are expired.
    let isExpired: Bool
}

class LoginSecondaryView: AuthenticationSecondaryViewDescription {

    let views: [ViewDescriptor]
    weak var actioner: AuthenticationActioner?

    init() {
        let resetPasswordButton = ButtonDescription(title: "signin.forgot_password".localized(uppercased: true), accessibilityIdentifier: "forgot_password")
        views = [resetPasswordButton]

        resetPasswordButton.buttonTapped = { [weak self] in
            self?.actioner?.executeAction(.openURL(.wr_passwordReset))
        }
    }

}

/**
 * An authentication step to ask the user for login credentials.
 */

class LogInStepDescription: AuthenticationStepDescription {

    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?

    init() {
        backButton = BackButtonDescription()
        mainView = EmptyViewDescription()
        headline = "registration.signin.title".localized
        subtext = nil
        secondaryView = LoginSecondaryView()
    }

}
