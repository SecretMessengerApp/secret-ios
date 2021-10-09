
import Foundation

final class BackButtonDescription {
    var buttonTapped: (() -> ())? = nil
    var accessibilityIdentifier: String? = "backButton"
}

extension BackButtonDescription: ViewDescriptor {
    func create() -> UIView {
        let button = IconButton()
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
        button.setIconColor(UIColor.from(scheme: .iconNormal, variant: .light), for: .normal)
        button.setIconColor(UIColor.from(scheme: .textDimmed, variant: .light), for: .highlighted)
        let iconType: StyleKitIcon = UIApplication.isLeftToRightLayout ? .backArrow : .forwardArrow
        button.setIcon(iconType, size: .tiny, for: .normal)
        button.accessibilityIdentifier = accessibilityIdentifier
        button.addTarget(self, action: #selector(BackButtonDescription.backButtonTapped(_:)), for: .touchUpInside)
        button.sizeToFit()
        return button
    }

    @objc dynamic func backButtonTapped(_ sender: UIButton) {
        buttonTapped?()
    }
}

