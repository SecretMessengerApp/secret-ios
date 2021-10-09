

import Foundation

extension UIViewController {
    func presentInviteActivityViewController(with sourceView: UIView) {
        let shareItemProvider = ShareItemProvider(placeholderItem: "")
        let activityController = UIActivityViewController(activityItems: [shareItemProvider], applicationActivities: nil)

        activityController.excludedActivityTypes = [UIActivity.ActivityType.airDrop]

        activityController.configPopover(pointToView: sourceView)

        present(activityController, animated: true)
    }
}
