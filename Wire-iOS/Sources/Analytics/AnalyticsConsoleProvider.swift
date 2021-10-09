
import Foundation
import WireSystem

fileprivate let tag = "<ANALYTICS>:"
final class AnalyticsConsoleProvider : NSObject {
    
    let zmLog = ZMSLog(tag: tag)
    var optedOut = false

    public required override init() {
        super.init()
        ZMSLog.set(level: .info, tag: tag)
    }

}

extension AnalyticsConsoleProvider: AnalyticsProvider {
    public var isOptedOut : Bool {
        get {
            return optedOut
        }
        
        set {
            zmLog.info("Setting Opted out: \(newValue)")
            optedOut = newValue
        }
    }
    
    private func print(loggingData data: [String: Any]) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted),
            let string = String(data: jsonData, encoding: .utf8) {
            zmLog.info(string)
        }
    }
    
    func tagEvent(_ event: String, attributes: [String : Any] = [:]) {
        
        let printableAttributes = attributes
        
        var loggingDict = [String : Any]()
        
        loggingDict["event"] = event
        
        if !printableAttributes.isEmpty {
            var localAttributes = [String : String]()
            printableAttributes.map({ (key, value) -> (String, String) in
                return (key, (value as AnyObject).description!)
            }).forEach({ (key, value) in
                localAttributes[key] = value
            })
            loggingDict["attributes"] = localAttributes
        }
        
        print(loggingData: loggingDict)
    }
    
    func setSuperProperty(_ name: String, value: Any?) {
        print(loggingData: ["superProperty_\(name)" : value ?? "nil"])
    }

    func flush(completion: (() -> Void)?) {
        completion?()
    }
}

