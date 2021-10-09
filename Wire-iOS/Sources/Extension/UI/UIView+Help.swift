//
//  UIView+Help.swift
//  Wire-iOS
//

import Foundation

extension UIView {

    func currentViewController() -> UIViewController? {
        
        var n: UIResponder = self
        
        while true {
            n = n.next!
            if n is UIViewController {
                break
            }
        }
        
        return n as? UIViewController
    }
}
