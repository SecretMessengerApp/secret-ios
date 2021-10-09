
import UIKit

class AuthenticationNavigationBar: DefaultNavigationBar {

    override var colorSchemeVariant: ColorSchemeVariant {
        return .light
    }

    override func configureBackground() {
        isTranslucent = true
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
    }

}

extension AuthenticationNavigationBar {

    static func makeBackButton() -> IconButton {
        let button = IconButton(style: .default)
        button.setIcon(UIApplication.isLeftToRightLayout ? .backArrow : .forwardArrow, size: .tiny, for: .normal)
        button.setIconColor(scheme: .title, for: .normal)
        button.setIconColor(.graphiteAlpha40, for: .highlighted)
        button.contentHorizontalAlignment = UIApplication.isLeftToRightLayout ? .left : .right
        button.frame = CGRect(x: 0, y: 0, width: 32, height: 20)
        button.accessibilityIdentifier = "back"
        button.accessibilityLabel = "general.back".localized
        return button
    }

}
