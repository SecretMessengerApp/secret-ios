
import Foundation

/**
 * An authentication step to ask the user to log in again.
 */

class ReauthenticateStepDescription: AuthenticationStepDescription {

    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?

    init(prefilledCredentials: AuthenticationPrefilledCredentials?) {
        backButton = BackButtonDescription()
        mainView = EmptyViewDescription()
        headline = "registration.signin.title".localized

        switch prefilledCredentials?.primaryCredentialsType {
        case .email?:
            if prefilledCredentials?.isExpired == true {
                subtext = "signin_logout.email.subheadline".localized
            } else {
                subtext = "signin.email.missing_password.subtitle".localized
            }
        case .phone?:
            if prefilledCredentials?.isExpired == true {
                subtext = "signin_logout.phone.subheadline".localized
            } else {
                subtext = "signin.phone.missing_password.subtitle".localized
            }
        case .none:
            subtext = "signin_logout.subheadline".localized
        }

        secondaryView = LoginSecondaryView()
    }

}
