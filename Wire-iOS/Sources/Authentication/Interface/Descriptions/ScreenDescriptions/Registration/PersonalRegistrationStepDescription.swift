
import Foundation

/**
 * The step to start personal user registration.
 */

class PersonalRegistrationStepDescription: AuthenticationStepDescription {

    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?

    init() {
        backButton = BackButtonDescription()
        mainView = EmptyViewDescription()
        headline = "registration.personal.title".localized
        subtext = nil
        secondaryView = nil
    }

}
