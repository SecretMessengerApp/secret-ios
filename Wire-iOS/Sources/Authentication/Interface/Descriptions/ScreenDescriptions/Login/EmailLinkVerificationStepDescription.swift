
import Foundation

class EmailLinkVerificationStepDescription: AuthenticationStepDescription {

    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?

    init(emailAddress: String) {
        backButton = BackButtonDescription()
        mainView = EmailLinkVerificationMainView()
        headline = "team.activation_code.headline".localized
        subtext = "registration.verify_email.instructions".localized(args: emailAddress)
        secondaryView = VerifyEmailStepSecondaryView(canResend: false)
    }

}

class EmailLinkVerificationMainView: NSObject, ViewDescriptor, ValueSubmission {
    var valueSubmitted: ValueSubmitted?
    var valueValidated: ValueValidated?
    var acceptsInput: Bool = true
    var constraints: [NSLayoutConstraint] = []

    func create() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center

        let label = UILabel()
        let labelPadding = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        let labelContainer = ContentInsetView(label, inset: labelPadding)
        stack.addArrangedSubview(labelContainer)

        label.textAlignment = .center
        label.text = "registration.verify_email.resend.instructions".localized
        label.font = AuthenticationStepController.subtextFont
        label.textColor = .gray
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping

        let button = SolidButtonDescription(title: "team.activation_code.button.resend".localized, accessibilityIdentifier: "resend_button")
        button.valueSubmitted = valueSubmitted

        let buttonView = button.create()
        buttonView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        stack.addArrangedSubview(buttonView)

        return stack
    }

}
