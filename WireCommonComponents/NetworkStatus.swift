
import Foundation
import SystemConfiguration
import WireUtilities
import CoreTelephony

private let zmLog = ZMSLog(tag: "NetworkStatus")

public enum ServerReachability {
    /// Backend can be reached.
    case ok
    /// Backend can not be reached.
    case unreachable
}

extension Notification.Name {
    public static let NetworkStatus = Notification.Name("NetworkStatusNotification")
}

/// This class monitors the reachability of backend. It emits notifications to its observers if the status changes.
public final class NetworkStatus {

    private let reachabilityRef: SCNetworkReachability

    init() {
        var zeroAddress: sockaddr_in = sockaddr_in()
        bzero(&zeroAddress, MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        // Passes the reference of the struct
        guard let reachabilityRef = withUnsafePointer(to: &zeroAddress, { pointer in
            // Converts to a generic socket address
            return pointer.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) {
                // $0 is the pointer to `sockaddr`
                return SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, $0)
            }
        }) else {
            fatalError("reachabilityRef can not be inited")
        }

        self.reachabilityRef = reachabilityRef

        startReachabilityObserving()
    }

    deinit {
        SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode!.rawValue)
    }

    private func startReachabilityObserving() {
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        // Sets `self` as listener object
        context.info = UnsafeMutableRawPointer(Unmanaged<NetworkStatus>.passUnretained(self).toOpaque())

        if SCNetworkReachabilitySetCallback(reachabilityRef, reachabilityCallback, &context) {
            if SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode!.rawValue) {
                zmLog.info("Scheduled network reachability callback in runloop")
            } else {
                zmLog.error("Error scheduling network reachability in runloop")
            }
        } else {
            zmLog.error("Error setting network reachability callback")
        }
    }

    // MARK: - Public API

    /// The shared network status object (status of 0.0.0.0)
    static public var shared: NetworkStatus = NetworkStatus()

    /// Current state of the network.
    public var reachability: ServerReachability {
        var returnValue: ServerReachability = .unreachable
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags()

        if SCNetworkReachabilityGetFlags(reachabilityRef, &flags) {

            let reachable: Bool = flags.contains(.reachable)
            let connectionRequired: Bool = flags.contains(.connectionRequired)

            switch (reachable, connectionRequired) {
            case (true, false):
                zmLog.info("Reachability status: reachable and connected.")
                returnValue = .ok
            case (true, true):
                zmLog.info("Reachability status: reachable but connection required.")
            case (false, _):
                zmLog.info("Reachability status: not reachable.")
            }

        } else {
            zmLog.info("Reachability status could not be determined.")
        }

        return returnValue
    }

    // MARK: - Utilities

    private var reachabilityCallback: SCNetworkReachabilityCallBack = {
        (reachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) in
        guard let info = info else {
            assert(false, "info was NULL in ReachabilityCallback")
            
            return
        }
        
        let networkStatus = Unmanaged<NetworkStatus>.fromOpaque(info).takeUnretainedValue()
        
        // Post a notification to notify the client that the network reachability changed.
        NotificationCenter.default.post(name: Notification.Name.NetworkStatus, object: networkStatus)
    }
}
