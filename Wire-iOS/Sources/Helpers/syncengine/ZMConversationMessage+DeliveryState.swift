
import Foundation
import WireDataModel

extension ZMConversationMessage {
    var shouldShowDeliveryState: Bool {
        return !Message.isPerformedCall(self) &&
               !Message.isMissedCall(self)
    }
}
