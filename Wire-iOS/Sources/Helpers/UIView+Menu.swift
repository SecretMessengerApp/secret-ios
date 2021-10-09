

import Foundation
import UIKit

extension UIView {
        
    /// The reason why we are touching the window here is to workaround a bug where,
    /// We now force the window to be the key window and to be the first responder to ensure that we can
    /// show the menu controller.
    /// ref: https://stackoverflow.com/questions/59176844/uimenucontroller-is-not-visible-in-ios-13-2/62578001#62578001
    func prepareShowingMenu() {
        window?.makeKey()
        window?.becomeFirstResponder()
        becomeFirstResponder()
    }
}

extension UIViewController {
    
    func prepareShowingMenu() {
        view.prepareShowingMenu()
        becomeFirstResponder()
    }
}
