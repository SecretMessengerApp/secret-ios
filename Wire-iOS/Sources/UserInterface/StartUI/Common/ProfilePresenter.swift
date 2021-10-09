
import Foundation
import UIKit
import WireDataModel

final class ProfilePresenter: NSObject, ViewControllerDismisser {

    var profileOpenedFromPeoplePicker = false
    var keyboardPersistedAfterOpeningProfile = false

    private var presentedFrame: CGRect = .zero
    private weak var viewToPresentOn: UIView?
    private weak var controllerToPresentOn: UIViewController?
    private var onDismiss: (() -> Void)?
    private let transitionDelegate = TransitionDelegate()

    override init() {
        super.init()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deviceOrientationChanged),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    @objc
    func deviceOrientationChanged(_ notification: Notification?) {
        guard
            let controllerToPresentOn = controllerToPresentOn,
            controllerToPresentOn.isIPadRegular()
            else { return }

        ZClientViewController.shared?.transitionToList(animated: false, completion: nil)

        guard
            viewToPresentOn != nil,
            let presentedViewController = controllerToPresentOn.presentedViewController
            else { return }

        presentedViewController.popoverPresentationController?.sourceRect = presentedFrame
        presentedViewController.preferredContentSize = presentedViewController.view.frame.insetBy(dx: -0.01, dy: 0.0).size
    }

    @objc
    func presentProfileViewController(
        for user: UserType,
        in controller: UIViewController?,
        from rect: CGRect,
        onDismiss: @escaping () -> Void
    ) {

        profileOpenedFromPeoplePicker = true
        viewToPresentOn = controller?.view
        controllerToPresentOn = controller
        presentedFrame = rect

        self.onDismiss = onDismiss
    
        let profileViewController = ProfileViewController(user: user, viewer: SelfUser.current, context: .search)
        profileViewController.delegate = self
        profileViewController.viewControllerDismisser = self

        let navigationController = profileViewController.wrapInNavigationController()
        navigationController.transitioningDelegate = transitionDelegate
        navigationController.modalPresentationStyle = .formSheet

        controllerToPresentOn?.present(navigationController, animated: true)
    }

    func dismiss(viewController: UIViewController, completion: (() -> Void)? = nil) {
        viewController.dismiss(animated: true) {
            completion?()
            self.onDismiss?()
            self.controllerToPresentOn = nil
            self.viewToPresentOn = nil
            self.presentedFrame = .zero
            self.onDismiss = nil
        }
    }
}


private class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return ZoomTransition(interactionPoint: .init(x: 0.5, y: 0.5), reversed: false)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ZoomTransition(interactionPoint: .init(x: 0.5, y: 0.5), reversed: true)
    }

}
