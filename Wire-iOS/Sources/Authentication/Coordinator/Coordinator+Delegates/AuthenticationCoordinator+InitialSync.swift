
import Foundation

extension AuthenticationCoordinator: ZMInitialSyncCompletionObserver {

    /// Called when the initial sync for the new user has completed.
    func initialSyncCompleted() {
        eventResponderChain.handleEvent(ofType: .initialSyncCompleted)
    }

}
