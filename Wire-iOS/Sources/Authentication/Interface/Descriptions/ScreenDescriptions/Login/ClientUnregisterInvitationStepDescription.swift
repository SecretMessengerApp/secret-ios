
import Foundation

/**
 * The view that displays the message to inform the user that they have too many devices.
 */

class ClientUnregisterInvitationStepDescription: AuthenticationStepDescription {

    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?

    init() {
        backButton = BackButtonDescription()
        headline = "registration.signin.too_many_devices.title".localized
        subtext = "registration.signin.too_many_devices.subtitle".localized

        mainView = SolidButtonDescription(title: "registration.signin.too_many_devices.manage_button.title".localized, accessibilityIdentifier: "manage_devices")
        secondaryView = nil
    }

}

