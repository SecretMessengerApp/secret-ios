
import Foundation
import AppCenterAnalytics

class BIEvent {
    ///  track a event
    static func track(_ eventName: String, withProperties properties: [String : String]? = nil) {
        MSAnalytics.trackEvent(eventName, withProperties: properties)
#if !DEBUG
        print("[BI] \(eventName)")
#endif
    }
}
