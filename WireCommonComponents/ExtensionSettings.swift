
import Foundation
import WireUtilities

private enum ExtensionSettingsKey: String {

    case disableCrashAndAnalyticsSharing = "disableCrashAndAnalyticsSharing"
    case disableLinkPreviews = "disableLinkPreviews"

    static var all: [ExtensionSettingsKey] {
        return [
            .disableLinkPreviews,
            .disableCrashAndAnalyticsSharing
        ]
    }

    private var defaultValue: Any? {
        switch self {
        // Always disable analytics by default.
        case .disableCrashAndAnalyticsSharing: return true
        case .disableLinkPreviews: return false
        }
    }

    static var defaultValueDictionary: [String: Any] {
        return all.reduce([:]) { result, current in
            var mutableResult = result
            mutableResult[current.rawValue] = current.defaultValue
            return mutableResult
        }
    }

}

@objc public class ExtensionSettings: NSObject {

    @objc public static let shared = ExtensionSettings(defaults: .shared()!)

    private let defaults: UserDefaults

    @objc public init(defaults: UserDefaults) {
        self.defaults = defaults
        super.init()
        setupDefaultValues()
    }

    private func setupDefaultValues() {
        defaults.register(defaults: ExtensionSettingsKey.defaultValueDictionary)
    }

    @objc public func reset() {
        ExtensionSettingsKey.all.forEach {
            defaults.removeObject(forKey: $0.rawValue)
        }

        // As we purposely crash afterwards we manually call synchronize.
        defaults.synchronize()
    }

    @objc public var disableCrashAndAnalyticsSharing: Bool {
        get {
            return defaults.bool(forKey: ExtensionSettingsKey.disableCrashAndAnalyticsSharing.rawValue)
        }
        set {
            defaults.set(newValue, forKey: ExtensionSettingsKey.disableCrashAndAnalyticsSharing.rawValue)
        }
    }
    
    @objc public var disableLinkPreviews: Bool {
        get {
            return defaults.bool(forKey: ExtensionSettingsKey.disableLinkPreviews.rawValue)
        }
        set {
            defaults.set(newValue, forKey: ExtensionSettingsKey.disableLinkPreviews.rawValue)
        }
    }
}
