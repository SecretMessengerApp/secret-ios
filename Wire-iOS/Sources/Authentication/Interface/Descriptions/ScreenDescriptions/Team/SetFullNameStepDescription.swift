
import Foundation

final class SetFullNameStepDescription: AuthenticationStepDescription {

    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?

    init() {
        backButton = BackButtonDescription()
        mainView = TextFieldDescription(placeholder: "team.full_name.textfield.placeholder".localized, actionDescription: "general.next".localized, kind: .name(isTeam: false))
        headline = "team.full_name.headline".localized
        subtext = nil
        secondaryView = nil
    }
}

