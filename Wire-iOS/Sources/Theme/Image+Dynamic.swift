//
// Secret
// Image+Dynamic.swift
//
// Created by Purkylin King on 2020/8/28.
//



import UIKit

public extension UIImage {
    // You can use imageView.tintColor to adjust image color
    func applyDynamic() -> UIImage {
        return self.withRenderingMode(.alwaysTemplate)
    }
    
    /// 给图片染色，相当于tintColor，针对 iOS13以前返回原始图片
    @objc func stain(for color: UIColor) -> UIImage {
        if #available(iOS 13.0, *) {
            return self.withTintColor(color)
        } else {
            return self
        }
    }
}
