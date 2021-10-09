

import Foundation

extension ZMConversation {

    func appendScreenShotMessage(
        sendUserId: String,
        completion: @escaping (() -> Void) = {}) {
        
        let msg = ConversationJSONMessage.ScreenShot.ScreenShotMsg(sendUserId: sendUserId).build()
        ZMUserSession.shared()?.enqueueChanges({
            self.append(jsonText: msg)
        }, completionHandler: completion)
    }
}
