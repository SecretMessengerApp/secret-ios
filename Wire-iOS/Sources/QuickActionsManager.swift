

import Foundation

extension UIApplicationShortcutItem {
    static let markAllAsReadType = "com.wire.shortcut.markAllAsRead"
    static let markAllAsRead = UIApplicationShortcutItem(type: markAllAsReadType,
                                                         localizedTitle: "shortcut.mark_all_as_read.title".localized,
                                                         localizedSubtitle: nil,
                                                         icon: UIApplicationShortcutIcon(type: .taskCompleted),
                                                         userInfo: nil)
}

public final class QuickActionsManager: NSObject {
    let sessionManager: SessionManager
    let application: UIApplication
    
    init(sessionManager: SessionManager, application: UIApplication) {
        self.sessionManager = sessionManager
        self.application = application
        super.init()
        updateQuickActions()
    }
    
    
    func updateQuickActions() {
        guard Bundle.developerModeEnabled else {
            application.shortcutItems = []
            return
        }

        application.shortcutItems = [.markAllAsRead]
    }
    
    @objc func performAction(for shortcutItem: UIApplicationShortcutItem, completionHandler: ((Bool) -> Void)?) {
        switch shortcutItem.type {
        case UIApplicationShortcutItem.markAllAsReadType:
            sessionManager.markAllConversationsAsRead {
                completionHandler?(true)
            }
        default:
            break
        }
    }
}
