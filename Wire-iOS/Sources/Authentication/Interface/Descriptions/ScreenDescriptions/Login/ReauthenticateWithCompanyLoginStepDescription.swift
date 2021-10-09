
import Foundation

class ReauthenticateWithCompanyLoginStepDescription: AuthenticationStepDescription {

    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?

    init() {
        backButton = BackButtonDescription()
        headline = "registration.signin.title".localized
        subtext = "signin_logout.sso.subheadline".localized

        mainView = SolidButtonDescription(title: "signin_logout.sso.buton".localized, accessibilityIdentifier: "company_login")
        secondaryView = nil
    }

}

