
import Foundation
import UIKit

extension ConversationInputBarViewController {

    override var keyCommands: [UIKeyCommand]? {
        var commands: [UIKeyCommand] = []

        commands.append(UIKeyCommand(input: "\r", modifierFlags: .command, action: #selector(commandReturnPressed), discoverabilityTitle: "conversation.input_bar.shortcut.send".localized))

        if UIDevice.current.userInterfaceIdiom == .pad {
            commands.append(UIKeyCommand(input: "\r", modifierFlags: .shift, action: #selector(shiftReturnPressed), discoverabilityTitle: "conversation.input_bar.shortcut.newline".localized))
        }

        if inputBar.isEditing {
            commands.append(UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(escapePressed), discoverabilityTitle: "conversation.input_bar.shortcut.cancel_editing_message".localized))
        } else if inputBar.textView.text.count == 0 {
            commands.append(UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(upArrowPressed), discoverabilityTitle: "conversation.input_bar.shortcut.edit_last_message".localized))
        } else if let mentionsView = mentionsView as? UIViewController, !mentionsView.view.isHidden {
            commands.append(UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(upArrowPressedForMention), discoverabilityTitle: "conversation.input_bar.shortcut.choosePreviousMention".localized)) ///TODO: string rsc
            commands.append(UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(downArrowPressedForMention), discoverabilityTitle: "conversation.input_bar.shortcut.chooseNextMention".localized)) ///TODO: string rsc

        }

        return commands
    }

    @objc func upArrowPressedForMention() {
        mentionsView?.selectPreviousUser()
    }

    @objc func downArrowPressedForMention() {
        mentionsView?.selectNextUser()
    }

    @objc
    func commandReturnPressed() {
        sendText()
    }

    @objc
    func shiftReturnPressed() {
        guard let selectedTextRange = inputBar.textView.selectedTextRange else { return }

        inputBar.textView.replace(selectedTextRange, withText: "\n")
    }

    @objc
    func upArrowPressed() {
        delegate?.conversationInputBarViewControllerEditLastMessage()
    }

    @objc
    func escapePressed() {
        endEditingMessageIfNeeded()
    }

}
