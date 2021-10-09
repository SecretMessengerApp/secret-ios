

import Foundation
import UIKit

extension UIResponder {
    private static weak var currentFirstResponder: UIResponder?

    class var currentFirst: UIResponder? {
        currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return currentFirstResponder
    }

    @objc
    private func findFirstResponder(_ sender: Any?) {
        UIResponder.currentFirstResponder = self
    }
}
