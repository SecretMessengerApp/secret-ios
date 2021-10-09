
import Foundation

extension AppRootViewController {
    
    @objc
    public static func configureAppearance() {
        
        let navigationBarTitleBaselineOffset: CGFloat = 0
        
        let attributes: [NSAttributedString.Key : Any] = [.font: UIFont(11, .semibold), .baselineOffset: navigationBarTitleBaselineOffset]
        let barButtonItemAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [DefaultNavigationBar.self])
        barButtonItemAppearance.setTitleTextAttributes(attributes, for: .normal)
        barButtonItemAppearance.setTitleTextAttributes(attributes, for: .highlighted)
        barButtonItemAppearance.setTitleTextAttributes(attributes, for: .disabled)
    }
}
