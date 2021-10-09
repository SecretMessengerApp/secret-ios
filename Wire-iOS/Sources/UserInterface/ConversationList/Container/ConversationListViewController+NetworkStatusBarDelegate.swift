

import UIKit

extension ConversationListViewController: NetworkStatusBarDelegate {
    var bottomMargin: CGFloat {
        return CGFloat.NetworkStatusBar.bottomMargin
    }

    func showInIPad(networkStatusViewController: NetworkStatusViewController, with orientation: UIInterfaceOrientation) -> Bool {
        // do not show on iPad for any orientation in regular mode
        return false
    }
}
