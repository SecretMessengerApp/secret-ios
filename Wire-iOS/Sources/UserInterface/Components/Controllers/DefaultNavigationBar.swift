
import UIKit

class ClearNavigationBar: UINavigationBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        tintColor = .dynamic(scheme: .barTint)
        isTranslucent = true
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage.singlePixelImage(with: UIColor.clear)
    }
}

class DefaultNavigationBar : UINavigationBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    var colorSchemeVariant: ColorSchemeVariant {
        return ColorScheme.default.variant
    }
    
    func configure() {

        tintColor = .dynamic(scheme: .barTint)
        titleTextAttributes = DefaultNavigationBar.titleTextAttributes(for: colorSchemeVariant)
        configureBackground()

        let backIndicatorInsets = UIEdgeInsets(top: 0, left: 4, bottom: 2.5, right: 0)
        let img = StyleKitIcon.backArrow.makeImage(size: .tiny, color: .accent()).with(insets: backIndicatorInsets, backgroundColor: .clear)
        backIndicatorImage = img
        backIndicatorTransitionMaskImage = StyleKitIcon.backArrow.makeImage(size: .tiny, color: .accent()).with(insets: backIndicatorInsets, backgroundColor: .clear)
    }

    func configureBackground() {
        backgroundColor = .dynamic(scheme: .barBackground)
        isTranslucent = false
        barTintColor = .dynamic(scheme: .barBackground)
//        setBackgroundImage(UIImage.singlePixelImage(with: UIColor.dynamic(scheme: .barBackground)), for: .default)
        shadowImage = UIImage.singlePixelImage(with: UIColor.clear)
    }
    
    static func titleTextAttributes(for variant: ColorSchemeVariant) -> [NSAttributedString.Key : Any] {
        return [.font: UIFont(16, .semibold),
                .foregroundColor: UIColor.dynamic(scheme: .title),
                .baselineOffset: 1.0]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureBackground()
    }
}

extension UIViewController {

    @objc
    func wrapInNavigationController(_ navigationControllerClass: UINavigationController.Type) -> UINavigationController {
        return wrapInNavigationController(navigationControllerClass: navigationControllerClass, navigationBarClass: DefaultNavigationBar.self)
    }

    @objc
    func wrapInNavigationController() -> UINavigationController {
        return wrapInNavigationController(navigationControllerClass: RotationAwareNavigationController.self, navigationBarClass: DefaultNavigationBar.self)
    }
    
    func wrapInTransparentNavigationController() -> UINavigationController {
        return wrapInNavigationController(navigationControllerClass: RotationAwareNavigationController.self, navigationBarClass: ClearNavigationBar.self)
    }
    
    func wrapInNavigationController(navigationControllerClass: UINavigationController.Type = RotationAwareNavigationController.self,
                                    navigationBarClass: AnyClass? = DefaultNavigationBar.self) -> UINavigationController {
        let navigationController = navigationControllerClass.init(navigationBarClass: navigationBarClass, toolbarClass: nil)
        navigationController.setViewControllers([self], animated: false)
        return navigationController
    }

    // MARK: - present
    func wrapInNavigationControllerAndPresent(from viewController: UIViewController) -> UINavigationController {
        let navigationController = wrapInNavigationController()
        navigationController.modalPresentationStyle = .formSheet
        viewController.present(navigationController, animated: true)

        return navigationController
    }

}
