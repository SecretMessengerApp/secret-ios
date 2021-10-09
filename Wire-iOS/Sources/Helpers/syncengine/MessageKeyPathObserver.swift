
import Foundation

/// Observes a single key path in `MessageChangeInfo` and calls a change handler when the key path changes.
///
/// The observer is active as long as the `MessageKeyPathObserver` instance is retained.
class MessageKeyPathObserver: NSObject, ZMMessageObserver {
    
    typealias ChangedBlock = (_ message: ZMConversationMessage) -> Void
    
    private let keypath: KeyPath<MessageChangeInfo, Bool>
    private var token: Any?
    
    var onChanged: ChangedBlock?
    
    init?(message: ZMConversationMessage, keypath: KeyPath<MessageChangeInfo, Bool>, _ changed: ChangedBlock? = nil) {
        guard let session = ZMUserSession.shared() else { return nil }
        
        self.keypath = keypath
        
        super.init()
        
        self.onChanged = changed
        self.token = MessageChangeInfo.add(observer: self, for: message, userSession: session)
    }
    
    func messageDidChange(_ changeInfo: MessageChangeInfo) {
        guard changeInfo[keyPath: keypath] else { return }
    
        onChanged?(changeInfo.message)
    }
    
}
