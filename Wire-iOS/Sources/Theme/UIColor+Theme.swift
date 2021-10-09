//
// Secret
// UIColor+Theme.swift
//
// Created by Purkylin King on 2020/8/28.
//



import UIKit

// This is a draft, only for swift in the future
fileprivate extension UIColor {
    enum Theme {
        // MARK: Text
        static let title: UIColor = ColorFactory.make(light: "#333", dark: "#F5F5F5")
        static let subtitle: UIColor = ColorFactory.make(light: "#666", dark: "#A1A1A1")
        static let title2: UIColor = ColorFactory.make(light: "#999", dark: "#EBEBF599")
        static let barTint: UIColor = ColorFactory.make(light: "#000", dark: "#BCBCBC")
        
        // MARK: Background
        static let background: UIColor = ColorFactory.make(light: "#FFF", dark: "#000")
        static let barBackground: UIColor = ColorFactory.make(light: "#FFF", dark: "#111")
        static let inputBackground: UIColor = ColorFactory.make(light: "#EFEFF0", dark: "#1C1C1E")
        static let groupBackground: UIColor = ColorFactory.make(light: "#f7f7f7", dark: "#000")
        static let panelBackground: UIColor = ColorFactory.make(light: "#FFF", dark: "#2C2C2C")
        static let cellBackground: UIColor = ColorFactory.make(light: "#FFF", dark: "#111")
        static let cellSelectedBackground: UIColor = ColorFactory.make(light: "#F7F7F7", dark: "#2C2C2E")

        // MARK: Other
        static let separator: UIColor = ColorFactory.make(light: "#DCDCDC", dark: "#38383A")
        
        static func custom(light: String, dark: String) -> UIColor {
            return ColorFactory.make(light: light, dark: dark)
        }
    }
}

// MARK: Usage
fileprivate func test() {
//    UIColor.Theme.custom(light: "#ABA", dark: "#000")
//    UIColor.Theme.brand
}
