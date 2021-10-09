
import Foundation

final class PlaceButtonDescription {
    var buttonTapped: (() -> ())? = nil
    let title: String
    let accessibilityIdentifier: String
    
    init(title: String, accessibilityIdentifier: String) {
        self.title = title
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

extension PlaceButtonDescription: ViewDescriptor {
    func create() -> UIView {
        let button = UIButton()
        button.titleLabel?.font = AuthenticationStepController.textButtonFont
        let color = UIColor.Team.textColor
        button.setTitleColor(color, for: .normal)
        button.setTitleColor(color.withAlphaComponent(0.6), for: .highlighted)
        
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        button.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title.localizedUppercase, for: .normal)
        button.accessibilityIdentifier = self.accessibilityIdentifier
        button.addTarget(self, action: #selector(ButtonDescription.buttonTapped(_:)), for: .touchUpInside)
        button.alpha = 0
        return button
    }
    
    @objc dynamic func buttonTapped(_ sender: UIButton) {
        buttonTapped?()
    }
}
