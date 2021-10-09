
import UIKit

/**
 * A view that displays a solid button.
 */

class SolidButtonDescription: ValueSubmission {
    let title: String
    let accessibilityIdentifier: String

    var valueSubmitted: ValueSubmitted?
    var valueValidated: ValueValidated?
    var acceptsInput: Bool = true

    init(title: String, accessibilityIdentifier: String) {
        self.title = title
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

extension SolidButtonDescription: ViewDescriptor {
    func create() -> UIView {
        let button = IconButton()
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor(white: 1, alpha: 0.6), for: .highlighted)
        button.titleLabel?.font = FontSpec(.normal, .semibold).font
        button.setBackgroundImageColor(UIColor.Team.activeButton, for: .normal)

        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        button.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title.localizedUppercase, for: .normal)
        button.accessibilityIdentifier = self.accessibilityIdentifier
        button.addTarget(self, action: #selector(ButtonDescription.buttonTapped(_:)), for: .touchUpInside)

        let buttonContainer = UIView()
        buttonContainer.addSubview(button)
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 200),
            button.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            button.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
            button.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor)
        ])

        return buttonContainer
    }

    @objc dynamic func buttonTapped(_ sender: UIButton) {
        valueSubmitted?(())
    }
}
