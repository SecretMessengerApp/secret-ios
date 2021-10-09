
import Foundation
import SafariServices

class SetTeamNameStepSecondaryView: AuthenticationSecondaryViewDescription {
    let views: [ViewDescriptor]
    weak var actioner: AuthenticationActioner?

    init() {
        let whatIsWire = ButtonDescription(title: "team.name.whatiswireforteams".localized, accessibilityIdentifier: "wire_for_teams_button")
        views = [whatIsWire]

        whatIsWire.buttonTapped = { [weak self] in
            let url = URL.wr_createTeamFeatures.appendingLocaleParameter
            self?.actioner?.executeAction(.openURL(url))
        }
    }
}

final class SetTeamNameStepDescription: AuthenticationStepDescription {

    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?

    init() {
        backButton = BackButtonDescription()
        mainView = TextFieldDescription(placeholder: "team.name.textfield.placeholder".localized, actionDescription: "general.next".localized, kind: .name(isTeam: true))
        headline = "team.name.headline".localized
        subtext = "team.name.subheadline".localized
        secondaryView = SetTeamNameStepSecondaryView()
    }
}

