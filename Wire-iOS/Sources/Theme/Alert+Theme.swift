

import UIKit

extension UIAlertController {
    /// Apply theme to actions
    func applyTheme() {
        self.actions.forEach { action in
            if self.preferredStyle == .actionSheet {
                if action.style != .destructive {
                    let color = UIColor.dynamic(light: .init(hex: "#000"), dark: .init(hex: "#EBEBF599"))
                    action.titleTextColor = color
                }
            } else {
                if action.style != .destructive {
                    action.titleTextColor = .dynamic(scheme: .alertButton)
                }
            }
        }
        
        safeActionSheet()
    }
    

    private func safeActionSheet() {
        if self.preferredStyle == .actionSheet {
            
            if let window = UIApplication.shared.keyWindow, UIScreen.isPad {
                if self.popoverPresentationController?.sourceView == nil && self.popoverPresentationController?.barButtonItem == nil {
                    self.popoverPresentationController?.permittedArrowDirections = []
                    self.popoverPresentationController?.sourceView = window
                    self.popoverPresentationController?.sourceRect = CGRect(origin: window.frame.center, size: .zero)
                }
            }
        }
    }
}

extension UIAlertAction {
    var titleTextColor: UIColor? {
        get {
            return self.value(forKey: "titleTextColor") as? UIColor
        } set {
            self.setValue(newValue, forKey: "titleTextColor")
        }
    }
}


