//
//  LXJTools.swift
//


import UIKit
import AVFoundation

class WRTools: NSObject {
    
    static func getBundleShortVersionString() -> String {
        let infoDictionary = Bundle.main.infoDictionary
        return infoDictionary? ["CFBundleShortVersionString"] as! String
    }
    
    static func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return currentViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        return base
    }
    
    static func playSystemSound() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    static func shake(_ style: UIImpactFeedbackGenerator.FeedbackStyle? = nil) {
        UIImpactFeedbackGenerator(style: style ?? .light).impactOccurred()
    }
    
    @objc static func playSendMessageSound() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        var soundID:SystemSoundID = 0
        guard let path = Bundle.main.path(forResource: "outgoing_message", ofType: "wav") else { return }
        let baseURL = NSURL(fileURLWithPath: path)
        AudioServicesCreateSystemSoundID(baseURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }
}
