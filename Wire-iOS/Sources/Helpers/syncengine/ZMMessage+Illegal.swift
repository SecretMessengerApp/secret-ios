

import Foundation

extension Message {
    
    @objc static func setIllegalMessage(_ message: ZMConversationMessage, illegal: Bool) {
        message.isIllegal = illegal
    }
    
    @objc static func isIllegalMessage(_ message: ZMConversationMessage) -> Bool {
        return message.isIllegal
    }
    
    @objc class func messageCanBeIllegal(_ message: ZMConversationMessage) -> Bool {
        return message.canBeIllegal
    }
}


extension ZMConversationMessage {
    
    var isIllegal: Bool {
        set {
            let status: MessageOperationStatus = newValue ? .on : .off
            let message = ZMMessage.addOperation(.illegal, status: status, onMessage: self)
            message?.unblock = true
        }
        get {
            if let message = self as? ZMMessage {
                return message.isillegal
            }
            return false
        }
    }
    
    var illegalOptName: String {
        if let message = self as? ZMMessage {
            return message.illegalUserName ?? ""
        }
        return ""
    }
}

