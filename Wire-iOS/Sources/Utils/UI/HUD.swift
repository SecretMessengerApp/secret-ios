//
//  HUD.swift
//


import UIKit
import MBProgressHUD

public class HUD: NSObject {
    
    static private var hud: MBProgressHUD?
    
    private class func create(
        view: UIView?,
        isMask: Bool = false,
        isUserInteractionEnabled: Bool = true,
        animationType: MBProgressHUDAnimation = .zoom
    ) -> MBProgressHUD? {
        guard let supView = view ?? UIApplication.shared.keyWindow else { return nil }
        hud?.removeFromSuperview()
        let hud = MBProgressHUD.showAdded(to: supView, animated: true)
        hud.isUserInteractionEnabled = !isUserInteractionEnabled
        hud.frame = supView.bounds
        hud.animationType = animationType
        if isMask {
            hud.backgroundView.color = UIColor(white: 0.0, alpha: 0.4)
        } else {
            hud.backgroundView.color = .clear
            hud.bezelView.backgroundColor = UIColor(white: 0.0, alpha: 0.9)
            hud.contentColor = .white
        }
        hud.removeFromSuperViewOnHide = true
        hud.show(animated: true)
        return hud
    }
}

extension HUD {
    
    public class func loading(
        on view: UIView? = nil,
        message: String? = nil,
        isMask: Bool = false
    ) {
        let hud = create(view: view, isMask: isMask)
        hud?.mode = .indeterminate
        hud?.label.text = message
        self.hud = hud
    }

    public class func text(
        _ message: String?,
        on view: UIView? = nil,
        isMask: Bool = false,
        delay: Double = 1.5,
        completion: (() -> Void)? = nil
    ) {
        let hud = create(view: view, isMask: isMask)
        hud?.mode = .text
        hud?.detailsLabel.font = UIFont(16, .regular)
        hud?.detailsLabel.text = message
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            hud?.hide(animated: true)
            completion?()
        }
        self.hud = hud
    }

    public class func success(
        _ message: String?,
        on view: UIView? = nil,
        completion: (() -> Void)? = nil
    ) {
        let hud = create(view: view, isMask: false)
        hud?.label.text = message
        hud?.label.numberOfLines = 0
        hud?.customView = UIImageView(image: UIImage(named: "mb_success_tips"))
        hud?.mode = .customView
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            hud?.hide(animated: true)
            completion?()
        }
        self.hud = hud
    }
    
    public class func error(
        _ err: Error,
        on view: UIView? = nil,
        completion: (() -> Void)? = nil
    ) {
        error(err.localizedDescription)
    }

    public class func error(
        _ message: String?,
        on view: UIView? = nil,
        completion: (() -> Void)? = nil
    ) {
        let hud = create(view: view, isMask: false)
        hud?.label.text = message
        hud?.label.numberOfLines = 0
        hud?.customView = UIImageView(image: UIImage(named: "mb_error_tips"))
        hud?.mode = .customView
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            hud?.hide(animated: true)
            completion?()
        }
        self.hud = hud
    }

    public class func hide() {
        hud?.hide(animated: true)
        hud = nil
    }
}
