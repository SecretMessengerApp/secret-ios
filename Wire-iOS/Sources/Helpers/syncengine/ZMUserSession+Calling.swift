
import Foundation

extension ZMUserSession {
    
    var isCallOngoing: Bool {
        guard let callCenter = callCenter else { return false }
        let conversationIds = callCenter.nonIdleCalls.compactMap { (key: UUID, value: CallState) -> UUID? in
            switch value {
            case .establishedDataChannel, .established, .answered, .outgoing:
                return key
            default:
                return nil
            }
        }
        return !conversationIds.isEmpty
    }
    
    var priorityCallConversation: ZMConversation? {
        guard let callNotificationStyle = SessionManager.shared?.callNotificationStyle else { return nil }
        guard let callCenter = self.callCenter else { return nil }
        
        let conversationsWithIncomingCall = callCenter.nonIdleCallConversations(in: self).filter({ conversation -> Bool in
            guard let callState = conversation.voiceChannel?.state else { return false }
            
            switch callState {
            case .incoming(video: _, shouldRing: true, degraded: _):
                return conversation.mutedMessageTypesIncludingAvailability == .none && callNotificationStyle != .callKit
            default:
                return false
            }
        })
        
        if conversationsWithIncomingCall.count > 0 {
            return conversationsWithIncomingCall.last
        }
        
        return ongoingCallConversation
    }
    
    var ongoingCallConversation: ZMConversation? {
        guard let callCenter = self.callCenter else { return nil }
        
        return callCenter.nonIdleCallConversations(in: self).first { (conversation) -> Bool in
            guard let callState = conversation.voiceChannel?.state else { return false }
            
            switch callState {
            case .answered, .established, .establishedDataChannel, .outgoing:
                return true
            default:
                return false
            }
        }
    }
    
    var ringingCallConversation: ZMConversation? {
        guard let callCenter = self.callCenter else { return nil }
        
        return callCenter.nonIdleCallConversations(in: self).first { (conversation) -> Bool in
            guard let callState = conversation.voiceChannel?.state else { return false }
            
            switch callState {
            case .incoming, .outgoing:
                return true
            default:
                return false
            }
        }
    }
}
