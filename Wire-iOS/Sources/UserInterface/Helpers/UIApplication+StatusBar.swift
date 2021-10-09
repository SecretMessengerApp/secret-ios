

import UIKit

extension UIApplication {
    
    static let wr_statusBarStyleChangeNotification: Notification.Name = Notification.Name("wr_statusBarStyleChangeNotification")

    func wr_updateStatusBarForCurrentControllerAnimated(_ animated: Bool) {
        wr_updateStatusBarForCurrentControllerAnimated(animated, onlyFullScreen: true)
    }

    func wr_updateStatusBarForCurrentControllerAnimated(_ animated: Bool, onlyFullScreen: Bool) {
        let statusBarHidden: Bool
        let statusBarStyle: UIStatusBarStyle
        
        if let topContoller = self.topmostViewController(onlyFullScreen: onlyFullScreen) {
            statusBarHidden = topContoller.prefersStatusBarHidden
            statusBarStyle = topContoller.preferredStatusBarStyle
        } else {
            statusBarHidden = true
            statusBarStyle = .default
        }
        
        var changed = false
        
        if (self.isStatusBarHidden != statusBarHidden) {
            self.wr_setStatusBarHidden(statusBarHidden, with: animated ? .fade : .none)
            changed = true
        }
        
        if self.statusBarStyle != statusBarStyle {
            self.wr_setStatusBarStyle(statusBarStyle, animated: animated)
            changed = true
        }
        
        if changed {
            NotificationCenter.default.post(name: type(of: self).wr_statusBarStyleChangeNotification, object: self)
        }
    }

    /// return the visible window on the top most which fulfills these conditions:
    /// 1. the windows has rootViewController
    /// 2. CallWindowRootViewController is in use and voice channel controller is active
    /// 3. the window's rootViewController is AppRootViewController
    var topMostVisibleWindow: UIWindow? {
        let orderedWindows = windows.sorted { win1, win2 in
            win1.windowLevel < win2.windowLevel
        }

        let visibleWindow = orderedWindows.filter {
            guard let controller = $0.rootViewController else {
                return false
            }

            if let callWindowRootController = controller as? CallWindowRootViewController {
                return callWindowRootController.isDisplayingCallOverlay
            } else if controller is AppRootViewController  {
                return true
            }
            
            return false
        }

        return visibleWindow.last
    }


    /// Get the top most view controller
    ///
    /// - Parameter onlyFullScreen: if false, also search for all kinds of presented view controller
    /// - Returns: the top most view controller 
    func topmostViewController(onlyFullScreen: Bool = true) -> UIViewController? {

        guard let window = topMostVisibleWindow,
            var topController = window.rootViewController else {
                return .none
        }
        
        while let presentedController = topController.presentedViewController,
            (!onlyFullScreen || presentedController.modalPresentationStyle == .fullScreen) {
            topController = presentedController
        }
        
        return topController
    }
    
    @available(iOS, deprecated: 9.0)
    func wr_setStatusBarStyle(_ style: UIStatusBarStyle, animated: Bool) {
        self.setStatusBarStyle(style, animated: animated)
    }
    
    @available(iOS, deprecated: 9.0)
    func wr_setStatusBarHidden(_ hidden: Bool, with animation: UIStatusBarAnimation) {
        self.setStatusBarHidden(hidden, with: animation)
    }

}

