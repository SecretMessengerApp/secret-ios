
import Foundation

extension UINavigationController {
    
    func closeItem() -> UIBarButtonItem {
        let item = UIBarButtonItem(icon: .cross, target: self, action: #selector(closeTapped))
        item.accessibilityIdentifier = "close"
        item.accessibilityLabel = "general.close".localized
        return item
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
