
import Foundation

extension ZMConversationMessage {

    /// Return the percentage (range: 0 to 1) to destruct of a ephemeral message.
    /// Return nil if self is not a ephemeral message or invalid deletionTimeout or deliveryState is pending
    var countdownProgress: Double? {
        guard deliveryState != .pending,
              let destructionDate = destructionDate, deletionTimeout > 0 else { return nil }

        return 1 - destructionDate.timeIntervalSinceNow / deletionTimeout
    }
}
