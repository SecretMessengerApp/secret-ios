
import Foundation
import UIKit

final class CallWindowRootViewController: UIViewController {
    
    private var callController: CallController?
    
    func minimizeOverlay(animated: Bool, completion: Completion?) {
        guard let callController = callController else {
            completion?()
            return
        }
        
        callController.minimizeCall(animated: animated, completion: completion)
    }
    
    var isDisplayingCallOverlay: Bool {
        return callController?.activeCallViewController != nil
    }
    
    private var child: UIViewController? {
        return callController?.activeCallViewController ?? topmostViewController()
    }

    override var childForStatusBarStyle: UIViewController? {
        return child
    }

    override var childForStatusBarHidden: UIViewController? {
        return child
    }

    override var shouldAutorotate: Bool {
        if isHorizontalSizeClassRegular {
            return topmostViewController()?.shouldAutorotate ?? true
        }
        
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topmostViewController()?.supportedInterfaceOrientations ?? wr_supportedInterfaceOrientations
    }
    
    override func loadView() {
        view = PassthroughTouchesView()
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func transitionToLoggedInSession() {
        callController = CallController()
        callController?.targetViewController = self
    }
    
    func presentCallCurrentlyInProgress() {
        callController?.updateState()
    }
    
    private func topmostViewController() -> UIViewController? {
        guard let topmost = UIApplication.shared.topmostViewController() else { return nil }
        guard topmost != self, !topmost.isKind(of: CallWindowRootViewController.self) else { return nil }
        return topmost
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        view.window?.isHidden = false
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

