
import Foundation
import WireDataModel

private let disableEphemeralSending = false
private let disableEphemeralSendingInGroups = false

extension ZMConversation {
    var hasSyncedMessageDestructionTimeout: Bool {
        switch messageDestructionTimeout {
        case .synced(_)?:
            return true
        default:
            return false
        }
    }
}

final class ConversationInputBarButtonState {

    var sendButtonHidden: Bool {
        let disableSendButton: Bool? = Settings.shared[.sendButtonDisabled]
        return !hasText || editing || (disableSendButton == true && !markingDown)
    }

    var hourglassButtonHidden: Bool {
        return hasText || (conversationType != .oneOnOne && disableEphemeralSendingInGroups) || editing || ephemeral || disableEphemeralSending
    }

    var ephemeralIndicatorButtonHidden: Bool {
        return (conversationType != .oneOnOne && disableEphemeralSendingInGroups) || editing || !ephemeral || disableEphemeralSending
    }

    var ephemeralIndicatorButtonEnabled: Bool {
        return !ephemeralIndicatorButtonHidden && !syncedMessageDestructionTimeout
    }

    private var hasText: Bool {
        return textLength != 0
    }

    var ephemeral: Bool {
        return destructionTimeout != 0
    }

    private var textLength: Int = 0
    private var editing: Bool = false
    private var markingDown: Bool = false
    private var destructionTimeout: TimeInterval = 0
    private var conversationType: ZMConversationType = .oneOnOne
    private var mode: ConversationInputBarViewControllerMode = .textInput
    private var syncedMessageDestructionTimeout: Bool = false

    func update(textLength: Int, editing: Bool, markingDown: Bool, destructionTimeout: TimeInterval, conversationType: ZMConversationType, mode: ConversationInputBarViewControllerMode, syncedMessageDestructionTimeout: Bool) {
        self.textLength = textLength
        self.editing = editing
        self.markingDown = markingDown
        self.destructionTimeout = destructionTimeout
        self.conversationType = conversationType
        self.mode = mode
        self.syncedMessageDestructionTimeout = syncedMessageDestructionTimeout
    }
}
