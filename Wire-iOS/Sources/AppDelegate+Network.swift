
import Foundation

extension AppDelegate {

    /// @return YES if network is offline
    static var isOffline: Bool {
        return .unreachable == NetworkStatus.shared.reachability
    }

    var sessionManager: SessionManager? {
        return rootViewController.sessionManager
    }
}

