
import UIKit
import FormatterKit

extension ConversationViewController {

    /// The state that the guest bar should adopt in the current configuration.
    var currentGuestBarState: GuestsBarController.State {
        switch conversation.externalParticipantsState {
        case [.visibleGuests]:
            return .visible(labelKey: "conversation.guests_present", identifier: "label.conversationview.hasguests")
        case [.visibleServices]:
            return .visible(labelKey: "conversation.services_present", identifier: "label.conversationview.hasservices")
        case [.visibleGuests, .visibleServices]:
            return .visible(labelKey: "conversation.guests_services_present", identifier: "label.conversationview.hasguestsandservices")
        default:
            return .hidden
        }
    }

    /// Updates the visibility of the guest bar.
    func updateGuestsBarVisibility() {
        let currentState = self.currentGuestBarState
        guestsBarController.state = currentState

        if case .hidden = currentState {
            conversationBarController.dismiss(bar: guestsBarController)
        } else {
            conversationBarController.present(bar: guestsBarController)
        }
    }

    func setGuestBarForceHidden(_ isGuestBarForceHidden: Bool) {
        if isGuestBarForceHidden {
            guestsBarController.setState(.hidden, animated: true)
            guestsBarController.shouldIgnoreUpdates = true
        } else {
            guestsBarController.shouldIgnoreUpdates = false
            updateGuestsBarVisibility()
        }
    }
}
