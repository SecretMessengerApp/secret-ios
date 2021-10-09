
/// Block based convenience wrapper around `ZMInitialSyncCompletionObserver`.
/// The passed in handler closure will be called immediately in case the
/// initial sync has already been completed when creating an instance and
/// will be called when the internal observer fires otherwise.
/// The `isCompleted` flag can be queried to check the current state.
final class InitialSyncObserver: NSObject, ZMInitialSyncCompletionObserver {
    private var token: Any!
    private var handler: (Bool) -> Void
    
    /// Whether the initial sync has been completed yet.
    private(set) var isCompleted = false
    
    init(in userSession: ZMUserSession, handler: @escaping (Bool) -> Void) {
        self.handler = handler
        super.init()

        // Immediately call the handler in case the initial sync has
        // already been completed, register for updates otherwise.
        if userSession.hasCompletedInitialSync {
            handleCompletedSync()
        } else {
            token = ZMUserSession.addInitialSyncCompletionObserver(self, userSession: userSession)
        }
    }
    
    private func handleCompletedSync() {
        isCompleted = true
        handler(isCompleted)
    }
    
    // MARK: - ZMInitialSyncCompletionObserver
    
    func initialSyncCompleted() {
        handleCompletedSync()
        token = nil
    }
    
}
