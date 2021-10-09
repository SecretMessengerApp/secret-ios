
import UIKit

protocol ProfileFooterViewDelegate: class {

    /// Called when the footer wants to perform a single action, from the left button.
    func footerView(_ footerView: ProfileFooterView, shouldPerformAction action: ProfileAction)

    /// Called when the footer wants to present the list of actions, from the right button.
    func footerView(_ footerView: ProfileFooterView, shouldPresentMenuWithActions actions: [ProfileAction])

}

/**
 * The footer of to use in the profile details screen.
 */

final class ProfileFooterView: ConversationDetailFooterView {

    /// The object that will perform the actions on demand.
    weak var delegate: ProfileFooterViewDelegate?

    /// The action on the left button.
    var leftAction: ProfileAction?

    /// The actions hidden behind the ellipsis on the right.
    var rightActions: [ProfileAction]?

    // MARK: - Configuration

    override func setupButtons() {
        leftButton.accessibilityIdentifier = "left_button"
        rightButton.accessibilityIdentifier = "right_button"
        rightButton.accessibilityLabel = "meta.menu.accessibility_more_options_button".localized
    }

    /**
     * Configures the footer to display the specified actions.
     * - parameter actions: The actions to display in the footer.
     */

    func configure(with actions: [ProfileAction]) {
        // Separate the last and first actions
        var leftAction = actions.first
        var rightActions: [ProfileAction]

        if leftAction?.isEligibleForKeyAction == true {
            rightActions = Array(actions.dropFirst())
        } else {
            // If the first action is not eligible for key action, display
            // everything on the right
            leftAction = nil
            rightActions = actions
        }

        self.leftAction = leftAction
        self.rightActions = rightActions

        // Display the left action
        if let leftAction = leftAction {
            leftButton.setTitle(leftAction.buttonText.localizedUppercase, for: .normal)
            leftIcon = leftAction.keyActionIcon
        }

        // Display or hide the right action ellipsis
        if rightActions.isEmpty {
            rightIcon = nil
            rightButton.isHidden = true
        } else {
            rightIcon = .ellipsis
            rightButton.isHidden = false
        }
    }

    // MARK: - Events

    override func leftButtonTapped(_ sender: IconButton) {
        guard let leftAction = self.leftAction else { return }
        delegate?.footerView(self, shouldPerformAction: leftAction)
    }

    override func rightButtonTapped(_ sender: IconButton) {
        guard let rightActions = self.rightActions else { return }
        delegate?.footerView(self, shouldPresentMenuWithActions: rightActions)
    }

}

