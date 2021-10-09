
import Foundation
import WireSystem
import avs

enum SettingsLastScreen: Int {
    case none = 0
    case list
    case conversation
}

enum SettingsCamera: Int {
    case front
    case back
}

extension Notification.Name {
    static let SettingsColorSchemeChanged = Notification.Name("SettingsColorSchemeChanged")
}

enum SettingKey: String, CaseIterable {
    case disableMarkdown                        = "UserDefaultDisableMarkdown"
    case chatHeadsDisabled                      = "ZDevOptionChatHeadsDisabled"
    case lastPushAlertDate                      = "LastPushAlertDate"
    case voIPNotificationsOnly                  = "VoIPNotificationsOnly"
    case lastViewedConversation                 = "LastViewedConversation"
    case shortcutConversation                   = "ShortcutConversation"
    case shortcutConversations                  = "ShortcutConversations"
    case colorScheme                            = "ColorScheme"
    case lastViewedScreen                       = "LastViewedScreen"
    case preferredCameraFlashMode               = "PreferredCameraFlashMode"
    case preferredCamera                        = "PreferredCamera"
    case avsMediaManagerPersistentIntensity     = "AVSMediaManagerPersistentIntensity"
    case lastUserLocation                       = "LastUserLocation"
    case blackListDownloadInterval              = "ZMBlacklistDownloadInterval"
    case messageSoundName                       = "ZMMessageSoundName"
    case callSoundName                          = "ZMCallSoundName"
    case pingSoundName                          = "ZMPingSoundName"
    case sendButtonDisabled                     = "SendButtonDisabled"

    // MARK: Features disable keys
    case disableCallKit                         = "UserDefaultDisableCallKit"
    case enableBatchCollections                 = "UserDefaultEnableBatchCollections"
    case callingProtocolStrategy                = "CallingProtocolStrategy"
    // MARK: Link opening options
    case twitterOpeningRawValue                 = "TwitterOpeningRawValue"
    case mapsOpeningRawValue                    = "MapsOpeningRawValue"
    case browserOpeningRawValue                 = "BrowserOpeningRawValue"
    case didMigrateHockeySettingInitially       = "DidMigrateHockeySettingInitially"
    case callingConstantBitRate                 = "CallingConstantBitRate"
    case disableLinkPreviews                    = "DisableLinkPreviews"
    case conferenceCalling                      = "ConferenceCalling"
    case topConversationCollapsed               = "topConversationCollapsed"
}

/// Model object for locally stored (not in SE or AVS) user app settings
final class Settings {
    // MARK: - subscript
    subscript<T>(index: SettingKey) -> T? {
        get {
            return defaults.value(forKey: index.rawValue) as? T
        }
        set {
            defaults.set(newValue, forKey: index.rawValue)

            /// side effects of setter

            switch index {
            case .sendButtonDisabled:
                notifyDisableSendButtonChanged()
            case .messageSoundName,
                 .callSoundName,
                 .pingSoundName:
                AVSMediaManager.sharedInstance().configureSounds()
            case .disableCallKit:
                SessionManager.shared?.updateCallNotificationStyleFromSettings()
            case .callingConstantBitRate:
                SessionManager.shared?.useConstantBitRateAudio = newValue as? Bool ?? false
            case .conferenceCalling where newValue is Bool:
                // TODO: ToSwift settings useConferenceCalling
                break
//                SessionManager.shared?.useConferenceCalling = newValue as! Bool
            default:
                break
            }
        }
    }

    subscript<E: RawRepresentable>(index: SettingKey) -> E? {
        get {
            if let value: E.RawValue = defaults.value(forKey: index.rawValue) as? E.RawValue {
                return E(rawValue:value)
            }

            return nil
        }
        set {
            defaults.set(newValue?.rawValue, forKey: index.rawValue)
        }
    }

    subscript(index: SettingKey) -> LocationData? {
        get {
            if let value = defaults.value(forKey: index.rawValue) as? [String : Any] {
                return LocationData.locationData(fromDictionary: value)
            }
            
            return nil
        }
        set {
            defaults.set(newValue?.toDictionary(), forKey: index.rawValue)
        }
    }
    
    var blacklistDownloadInterval: TimeInterval {
        let HOURS_6 = 6 * 60 * 60
        let settingValue = defaults.integer(forKey: SettingKey.blackListDownloadInterval.rawValue)
        return TimeInterval(settingValue > 0 ? settingValue : HOURS_6)
    }

    /// These settings are not actually persisted, just kept in memory
    // Max audio recording duration in seconds
    var maxRecordingDurationDebug: TimeInterval = 0.0

    static let shared: Settings = Settings()

    init() {
        migrateAppCenterAndOptOutSettingsToSharedDefaults()
        restoreLastUsedAVSSettings()

        startLogging()

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    func migrateAppCenterAndOptOutSettingsToSharedDefaults() {
        if !defaults.bool(forKey: SettingKey.didMigrateHockeySettingInitially.rawValue) {
            ExtensionSettings.shared.disableLinkPreviews = Settings.disableLinkPreviews
            defaults.set(true, forKey: SettingKey.didMigrateHockeySettingInitially.rawValue)
        }
    }

    // Persist all the settings
    private func synchronize() {
        storeCurrentIntensityLevelAsLastUsed()
        defaults.synchronize()
    }

    @objc
    private func applicationDidEnterBackground(_ application: UIApplication) {
        synchronize()
    }

    static var disableLinkPreviews: Bool {
        get {
            return ExtensionSettings.shared.disableLinkPreviews
        }
        set {
            ExtensionSettings.shared.disableLinkPreviews = newValue
        }
    }
    
    func addObserver(_ observer: NSObject, for key: SettingKey, options: NSKeyValueObservingOptions) -> Any {
        return defaults.addObserver(observer, forKeyPath: key.rawValue, options: options, context: nil)
    }
    
    func removeObserver(_ observer: NSObject, for key: SettingKey) {
        defaults.removeObserver(observer, forKeyPath: key.rawValue, context: nil)
    }

    // MARK: - MediaManager
    func restoreLastUsedAVSSettings() {
        if let savedIntensity = defaults.object(forKey: SettingKey.avsMediaManagerPersistentIntensity.rawValue) as? NSNumber,
            let intensityLevel = AVSIntensityLevel(rawValue: UInt(savedIntensity.intValue)) {
            AVSMediaManager.sharedInstance().intensityLevel = intensityLevel
        } else {
            AVSMediaManager.sharedInstance().intensityLevel = .full
        }
    }

    func storeCurrentIntensityLevelAsLastUsed() {
        let level = AVSMediaManager.sharedInstance().intensityLevel.rawValue
        if level >= AVSIntensityLevel.none.rawValue && level <= AVSIntensityLevel.full.rawValue {
            defaults.setValue(NSNumber(value: level), forKey: SettingKey.avsMediaManagerPersistentIntensity.rawValue)
        }
    }

    // MARK: - Debug

    private func startLogging() {
        #if !targetEnvironment(simulator)
        loadEnabledLogs()
        #endif

        ZMSLog.startRecording(isInternal: Bundle.developerModeEnabled)
    }
}

final class SettingsObserver: NSObject {
    
    let key: SettingKey
    
    private let changed: (Any, Any) -> Void
    
    init(key: SettingKey, changed: @escaping (Any, Any) -> Void) {
        self.key = key
        self.changed = changed
        
        super.init()
        Settings.shared.addObserver(self, for: key, options: [.old, .new])
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard object != nil, let change = change, keyPath == key.rawValue else { return }
        changed(change[.oldKey] as Any, change[.newKey] as Any)
    }
    
    deinit {
        Settings.shared.removeObserver(self, for: key)
    }
}
