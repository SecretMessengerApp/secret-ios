
import Foundation
import WireDataModel

final class Analytics: NSObject {
    
    var provider: AnalyticsProvider?

    private static let sharedAnalytics = Analytics()
    
    @objc
    class func shared() -> Analytics {
        return sharedAnalytics
    }

    class func loadShared(withOptedOut optedOut: Bool) {
        //no-op
    }
    
    override init() {
        //no-op
    }
    
    required init(optedOut: Bool) {
        //no-op
    }
    
    func setTeam(_ team: Team?) {
        //no-op
    }
    
    func tagEvent(_ event: String, attributes: [String : Any]) {
        guard let attributes = attributes as? [String : NSObject] else { return }
        
        tagEvent(event, attributes: attributes)
    }

    //MARK: - OTREvents
    func tagCannotDecryptMessage(withAttributes userInfo: [AnyHashable : Any]?) {
        //no-op
    }
}

extension Analytics: AnalyticsType {
    func setPersistedAttributes(_ attributes: [String : NSObject]?, for event: String) {
        //no-op
    }
    
    func persistedAttributes(for event: String) -> [String : NSObject]? {
        //no-op
        return nil
    }
    
    /// Record an event with no attributes
    func tagEvent(_ event: String) {
        //no-op
    }
    
    /// Record an event with optional attributes.
    func tagEvent(_ event: String, attributes: [String : NSObject]) {
        //no-op
    }
}
