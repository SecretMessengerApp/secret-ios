
import Foundation

@objc protocol AnalyticsProvider: NSObjectProtocol {
    var isOptedOut: Bool { get set }

    /// Record an event with optional attributes.
    func tagEvent(_ event: String, attributes: [String : Any])

    /// Set a custom dimension
    func setSuperProperty(_ name: String, value: Any?)


    /// Force the AnalyticsProvider to process the queued data immediately
    ///
    /// - Parameter completion: an optional completion handler for when the flush has completed.
    func flush(completion: (() -> Void)?)
}
