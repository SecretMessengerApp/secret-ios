//
//  ConversationViewController+AutoHideNavibar.swift
//  Wire-iOS
//

import Foundation
extension ConversationViewController {
    
    func navigantionBarShouldHide(_ hidden: Bool) {
        self.navBarHidden = hidden
        let transform: CGAffineTransform = hidden ? CGAffineTransform(translationX: 0, y: -(UIScreen.safeArea.top + 44 + 12)) : .identity
        let delayTime: Double = hidden ? 0.0 : 1.0
        delay(delayTime) {
            self.contentViewController.changeTopRemindViewsState(hidden)
            UIView.animate(withDuration: 0.3, animations: {
                self.navBarContainer.view.transform = transform
            })
        }
    }
}
