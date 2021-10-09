

import Foundation


extension AuthenticationCoordinator {
    
    public func addInitialSyncCompletionObserver(usersessoin: ZMUserSession) {
        initialSyncObserver = ZMUserSession.addInitialSyncCompletionObserver(self, userSession: usersessoin)
    }

}
