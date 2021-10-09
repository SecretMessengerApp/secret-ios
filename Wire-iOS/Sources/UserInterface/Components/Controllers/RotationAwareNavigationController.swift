

import Foundation

final class RotationAwareNavigationController: UINavigationController, PopoverPresenter {
    
    // PopoverPresenter
    weak var presentedPopover: UIPopoverPresentationController?
    weak var popoverPointToView: UIView?    
    
    override var shouldAutorotate : Bool {
        if let topController = self.viewControllers.last {
            return topController.shouldAutorotate
        }
        else {
            return super.shouldAutorotate
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if let topController = self.viewControllers.last {
            return topController.supportedInterfaceOrientations
        }
        else {
            return super.supportedInterfaceOrientations
        }
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        if let topController = self.viewControllers.last {
            return topController.preferredInterfaceOrientationForPresentation
        }
        else {
            return super.preferredInterfaceOrientationForPresentation
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        if let topController = self.viewControllers.last {
            return topController.prefersStatusBarHidden
        }
        else {
            return super.prefersStatusBarHidden
        }
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        viewControllers.forEach { $0.hideDefaultButtonTitle() }
        
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hideDefaultButtonTitle()
        viewController.hidesBottomBarWhenPushed = true
        super.pushViewController(viewController, animated: animated)
    }
    
}
