
import Foundation
import SafariServices

class SetEmailStepSecondaryView: AuthenticationSecondaryViewDescription {
    let views: [ViewDescriptor] = []
    let learnMore: ButtonDescription

    weak var actioner: AuthenticationActioner?

    init() {
        self.learnMore = ButtonDescription(title: "team.email.button.learn_more".localized, accessibilityIdentifier: "learn_more_button")
        learnMore.buttonTapped = { [weak self] in
            let url = URL.wr_emailInUseLearnMore.appendingLocaleParameter
            self?.actioner?.executeAction(.openURL(url))
        }
    }

    func display(on error: Error) -> ViewDescriptor? {
        guard (error as NSError).userSessionErrorCode == .emailIsAlreadyRegistered else {
            return nil
        }

        return learnMore
    }
}

final class SetEmailStepDescription: AuthenticationStepDescription {

    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?

    init() {
        backButton = BackButtonDescription()
        mainView = TextFieldDescription(placeholder: "team.email.textfield.placeholder".localized, actionDescription: "general.next".localized, kind: .email)
        headline = "team.email.headline".localized
        subtext = "team.email.subheadline".localized
        secondaryView = SetEmailStepSecondaryView()
    }

}
