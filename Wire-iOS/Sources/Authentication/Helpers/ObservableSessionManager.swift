
import Foundation

/**
 * A protocol for session managers that provides a mechanism to observe user
 * session creation.
 */

protocol ObservableSessionManager: SessionManagerType {

    var activeUnauthenticatedSession: UnauthenticatedSession { get }

    /**
     * Registers an observer to monitor unauthenticated session creation.
     *
     * - parameter observer: The object that is subscribing to notifications.
     * - returns: A token object that holds a reference to the observer. Keep a strong
     * reference to this object as long as the observer is allocated. You should discard it
     * when the observer is deallocated to remove the observer,
     */

    func addUnauthenticatedSessionManagerCreatedSessionObserver(_ observer: SessionManagerCreatedSessionObserver) -> Any

    /**
     * Registers an observer to monitor user session creation.
     *
     * - parameter observer: The object that is subscribing to notifications.
     * - returns: A token object that holds a reference to the observer. Keep a strong
     * reference to this object as long as the observer is allocated. You should discard it
     * when the observer is deallocated to remove the observer,
     */

    func addSessionManagerCreatedSessionObserver(_ observer: SessionManagerCreatedSessionObserver) -> Any

    /// Deletes the selected account.
    func delete(account: Account)

}

extension SessionManager: ObservableSessionManager {}
