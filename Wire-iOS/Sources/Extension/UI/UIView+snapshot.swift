//
//  UIView+snapshot.swift
//  Wire-iOS
//


import UIKit.UIView

extension UIView {
    func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, UIScreen.main.scale)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
//        let renderer = UIGraphicsImageRenderer(size: bounds.size)
//        return renderer.image { _ in drawHierarchy(in: bounds, afterScreenUpdates: true) }
    }
}
