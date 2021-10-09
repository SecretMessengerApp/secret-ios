
import Foundation

extension ConversationInputBarViewController {
    @objc
    func locationButtonPressed(_ sender: IconButton?) {
        guard let parentViewConvtoller = self.parent else { return }

        let locationSelectionViewController = LocationSelectionViewController()
        locationSelectionViewController.modalPresentationStyle = .popover

        if let popover = locationSelectionViewController.popoverPresentationController,
           let imageView = sender?.imageView {

            popover.config(from: self,
                           pointToView: imageView,
                           sourceView: parentViewConvtoller.view)
        }

        locationSelectionViewController.title = conversation.displayName
        locationSelectionViewController.delegate = self
        parentViewConvtoller.present(locationSelectionViewController, animated: true)
    }
}

extension ConversationInputBarViewController: LocationSelectionViewControllerDelegate {
    func locationSelectionViewController(_ viewController: LocationSelectionViewController, didSelectLocationWithData locationData: LocationData) {
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation.append(location: locationData)
            Analytics.shared().tagMediaActionCompleted(.location, inConversation: self.conversation)
        }

        parent?.dismiss(animated: true)
    }

    func locationSelectionViewControllerDidCancel(_ viewController: LocationSelectionViewController) {
        parent?.dismiss(animated: true)
    }
}
