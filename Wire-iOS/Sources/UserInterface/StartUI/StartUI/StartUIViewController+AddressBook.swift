
import Foundation
import UIKit
import WireDataModel

extension StartUIViewController {

    var needsAddressBookPermission: Bool {
        let shouldSkip = AutomationHelper.sharedHelper.skipFirstLoginAlerts || ZMUser.selfUser().hasTeam
        return !AddressBookHelper.sharedHelper.isAddressBookAccessGranted && !shouldSkip
    }

    func presentShareContactsViewController() {
        let shareContactsViewController = ShareContactsViewController()
        shareContactsViewController.delegate = self
        navigationController?.pushViewController(shareContactsViewController, animated: true)
    }

}

extension StartUIViewController: ShareContactsViewControllerDelegate {
    
    func shareDidFinish(_ viewController: UIViewController) {
        viewController.dismiss(animated: true)
    }

    func shareDidSkip(_ viewController: UIViewController) {
        dismiss(animated: true) {
            UIApplication.shared.topmostViewController()?.presentInviteActivityViewController(with: self.quickActionsBar)
        }
    }
}
