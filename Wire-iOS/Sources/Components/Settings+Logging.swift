
import Foundation
import WireSystem

/// User default key for the array of enabled logs
private let enabledLogsKey = "WireEnabledZMLogTags"


extension Settings {
    
    /// Enable/disable a log
    func set(logTag: String, enabled: Bool) {
        ZMSLog.set(level: enabled ? .debug : .warn, tag: logTag)
        saveEnabledLogs()
    }
    
    /// Save to user defaults the list of logs that are enabled
    private func saveEnabledLogs() {
        let enabledLogs = ZMSLog.allTags.filter { tag in
            let level = ZMSLog.getLevel(tag: tag)
            return level == .debug || level == .info
        } as NSArray
        
        UserDefaults.shared().set(enabledLogs, forKey: enabledLogsKey)
    }
    
    /// Loads from user default the list of logs that are enabled
    func loadEnabledLogs() {
        var tagsToEnable: Set<String> = ["AVS", "Network", "SessionManager", "Conversations", "calling", "link previews", "event-processing", "huge-event-processing", "SyncStatus", "OperationStatus", "Push", "Crypto", "cryptobox"]

        if let savedTags = UserDefaults.shared().object(forKey: enabledLogsKey) as? Array<String> {
            tagsToEnable = Set(savedTags)
        }
        
        enableLogs(tagsToEnable)
    }
    
    private func enableLogs(_ tags : Set<String>) {
        tags.forEach { (tag) in
            ZMSLog.set(level: .debug, tag: tag)
        }
    }
}
