
import Foundation

extension UIViewController {
    
    func hideDefaultButtonTitle() {
        guard navigationItem.backBarButtonItem == nil else { return }
        
        hideBackButtonTitle()
    }
    
    func hideBackButtonTitle() {
        let item = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        item.accessibilityLabel = "back"
        navigationItem.backBarButtonItem = item
    }
    
    /// Get navbar height
    var navBarHeight: CGFloat {
        return self.navigationController?.navigationBar.frame.height ?? 0
    }
}
