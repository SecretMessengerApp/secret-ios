
import Foundation

class SettingsStyleNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.setBackgroundImage(UIImage(color: .red, andSize: CGSize(width: 1,height: 1)), for:.default)
        self.navigationBar.isTranslucent = false
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.titleTextAttributes = DefaultNavigationBar.titleTextAttributes(for: .dark)
        
        let navButtonAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        
        let attributes = [NSAttributedString.Key.font : UIFont(11, .semibold)]
        navButtonAppearance.setTitleTextAttributes(attributes, for: UIControl.State.normal)
        navButtonAppearance.setTitleTextAttributes(attributes, for: UIControl.State.highlighted)
        
    }
}
