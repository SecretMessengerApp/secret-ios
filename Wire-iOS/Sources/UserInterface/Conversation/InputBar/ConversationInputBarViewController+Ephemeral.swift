

import Foundation

extension ConversationInputBarViewController {

    @discardableResult
    func createEphemeralKeyboardViewController() -> EphemeralKeyboardViewController {
        let ephemeralKeyboardViewController = EphemeralKeyboardViewController(conversation: conversation)
        ephemeralKeyboardViewController.delegate = self
        self.ephemeralKeyboardViewController = ephemeralKeyboardViewController
        return ephemeralKeyboardViewController
    }

    func configureEphemeralKeyboardButton(_ button: IconButton) {
        button.addTarget(self, action: #selector(ephemeralKeyboardButtonTapped), for: .touchUpInside)
    }

    @objc func ephemeralKeyboardButtonTapped(_ sender: IconButton) {
        toggleEphemeralKeyboardVisibility()
    }
    
    fileprivate func toggleEphemeralKeyboardVisibility() {
        let isEphemeralControllerPresented = ephemeralKeyboardViewController != nil
        let isEphemeralKeyboardPresented = mode == .timeoutConfguration

        if !isEphemeralControllerPresented || !isEphemeralKeyboardPresented {
            presentEphemeralController()
        } else {
            dismissEphemeralController()
        }
    }
    
    private func presentEphemeralController() {
        let shouldShowPopover = traitCollection.horizontalSizeClass == .regular
        
        if shouldShowPopover {
            presentEphemeralControllerAsPopover()
        } else {
            // we only want to change the mode when we present a custom keyboard
            mode = .timeoutConfguration
            inputBar.textView.becomeFirstResponder()
        }
    }
    
    private func dismissEphemeralController() {
        let isPopoverPresented = ephemeralKeyboardViewController?.modalPresentationStyle == .popover
        
        if isPopoverPresented {
            ephemeralKeyboardViewController?.dismiss(animated: true, completion: nil)
            ephemeralKeyboardViewController = nil
        } else {
            mode = .textInput
        }
    }
    
    private func presentEphemeralControllerAsPopover() {
        createEphemeralKeyboardViewController()
        ephemeralKeyboardViewController?.modalPresentationStyle = .popover
        ephemeralKeyboardViewController?.preferredContentSize = CGSize.IPadPopover.pickerSize
        let pointToView: UIView = ephemeralIndicatorButton.isHidden ? hourglassButton : ephemeralIndicatorButton

        if let popover = ephemeralKeyboardViewController?.popoverPresentationController,
            let presentInView = self.parent?.view,
            let backgroundColor = ephemeralKeyboardViewController?.view.backgroundColor {
                popover.config(from: self,
                           pointToView: pointToView,
                           sourceView: presentInView)

            popover.backgroundColor = backgroundColor
            popover.permittedArrowDirections = .down
        }

        guard let controller = ephemeralKeyboardViewController else { return }
        self.parent?.present(controller, animated: true)
    }
    
    func updateEphemeralIndicatorButtonTitle(_ button: ButtonWithLargerHitArea) {
        guard let timerValue = conversation.destructionTimeout else {
            button.setTitle("", for: .normal)
            return
        }

        let title = timerValue.shortDisplayString
        button.setTitle(title, for: .normal)
    }
}

extension ConversationInputBarViewController: EphemeralKeyboardViewControllerDelegate {

    func ephemeralKeyboardWantsToBeDismissed(_ keyboard: EphemeralKeyboardViewController) {
        toggleEphemeralKeyboardVisibility()
    }

    func ephemeralKeyboard(_ keyboard: EphemeralKeyboardViewController, didSelectMessageTimeout timeout: TimeInterval) {
        inputBar.setInputBarState(.writing(ephemeral: timeout != 0 ? .message : .none), animated: true)
        updateIndicateButton()
        
        ZMUserSession.shared()?.enqueueChanges {
            if !self.conversation.hasSyncedDestructionTimeout {
                self.conversation.messageDestructionTimeout = .local(MessageDestructionTimeoutValue(rawValue: timeout))
            }
            self.updateRightAccessoryView()
        }
    }
    
}

extension ConversationInputBarViewController {
    var ephemeralState: EphemeralState {
        var state = EphemeralState.none
        if !sendButtonState.ephemeral {
            state = .none
        } else if self.conversation.hasSyncedMessageDestructionTimeout {
            state = .conversation
        } else {
            state = .message
        }
        
        return state
    }

    func updateInputBar() {
        inputBar.changeEphemeralState(to: ephemeralState)
        if conversation.hasSyncedMessageDestructionTimeout {
            dismissEphemeralController()
        }
    }
    
    func updateInputBarPlaceholder() {
        inputBar.updatePlaceholder()
        inputBar.updatePlaceholderColors()
    }
}
