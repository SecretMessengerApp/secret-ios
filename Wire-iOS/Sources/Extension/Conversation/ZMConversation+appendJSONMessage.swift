
import Foundation

extension ZMConversation {
    private func appendJsonMessage(onlyToSelf toSelf: Bool,
                                   jsonMessageString: String,
                                   completion: @escaping (() -> Void) = {}) {
        
        ZMUserSession.shared()?.enqueueChanges({
            let message = self.append(jsonText: jsonMessageString)
            if let msg = message as? ZMMessage {
           
                if toSelf {
                    msg.recipientUsers = [ZMUser.selfUser()]
                }
            }
            WRTools.playSendMessageSound()
        }, completionHandler: completion)
    }
}
