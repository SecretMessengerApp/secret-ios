//
//  ScreenInfo.swift
//  Wire-iOS
//

import Foundation

// TODO: delete the file

extension CGFloat {
    
    /// do not call these proprieties
    /// these should be delete
    @available(*, deprecated, message: "Please use auto layout")
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    @available(*, deprecated, message: "Please use auto layout")
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    @available(*, deprecated, message: "Please use auto layout")
    static var navgationBarHeight: CGFloat {
        return hasNotch ? 88 : 64
    }
    
    @available(*, deprecated, message: "Please use auto layout")
    static var statusBarHeight: CGFloat {
        return hasNotch ? 44 : 20
    }
    
    @available(*, deprecated, message: "Please use auto layout")
    static var tabBarHeight: CGFloat {
        return hasNotch ? 83 : 49
    }
    
    @available(*, deprecated, message: "Please use UIScreen.hasNotch")
    private static var hasNotch: Bool {
        if #available(iOS 12, *) {
            ///on iOS12 insets.top == 20 on device without notch.
            ///insets.top == 44 on device with notch.
            guard let window = UIApplication.shared.keyWindow else { return false }
            let insets = window.safeAreaInsets
            
            return insets.top > 20 || insets.bottom > 0
        } else if #available(iOS 11, *) {
            guard let window = UIApplication.shared.keyWindow else { return false }
            let insets = window.safeAreaInsets
            // if top or bottom insets are greater than zero, it means that
            // the screen has a safe area (e.g. iPhone X)
            return insets.top > 0 || insets.bottom > 0
        } else {
            return false
        }
    }
}
