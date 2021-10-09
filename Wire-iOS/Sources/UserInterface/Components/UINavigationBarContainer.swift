
import UIKit
import Cartography

final class UINavigationBarContainer: UIViewController {

    let portraitNavbarHeight: CGFloat = 44.0

    var navigationBar: UINavigationBar
    
    init(_ navigationBar: UINavigationBar) {
        self.navigationBar = navigationBar
        super.init(nibName: nil, bundle: nil)
        self.view.addSubview(navigationBar)
        self.view.backgroundColor = UIColor.dynamic(scheme: .barBackground)
        createConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createConstraints() {
        constrain(navigationBar, view) { navigationBar, view in
            navigationBar.height == portraitNavbarHeight
            navigationBar.left == view.left
            navigationBar.right == view.right
            navigationBar.bottom == view.bottom
        }

//        navigationBar.topAnchor.constraint(equalTo: safeTopAnchor).isActive = true
    }
}
