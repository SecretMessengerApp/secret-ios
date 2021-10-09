//
import Foundation

enum BackupEvent: Event {
    case importSucceeded
    case importFailed
    case exportSucceeded
    case exportFailed
    
    var name: String {
        switch self {
        case .importSucceeded: return "history.restore_succeeded"
        case .importFailed: return "history.restore_failed"
        case .exportSucceeded: return "history.backup_succeeded"
        case .exportFailed: return "history.backup_failed"
        }
    }
    
    var attributes: [AnyHashable : Any]? {
        return nil
    }
}
