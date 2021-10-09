
import Foundation

extension UnauthenticatedSession {
    
    @objc
    static var sharedSession : UnauthenticatedSession? {
        
        return AppDelegate.shared.unauthenticatedSession
        
    }
    
}
