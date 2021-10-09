
import Foundation

@objc
protocol ZMUserSessionInterface: NSObjectProtocol {
    func performChanges(_ block: @escaping () -> ())
    func enqueueChanges(_ block: @escaping () -> ())
    func enqueueChanges(_ block: @escaping () -> Void, completionHandler: (() -> Void)!)

    var isNotificationContentHidden : Bool { get set }
}

// an interface for ZMUserSession's Swift-only functions
protocol UserSessionSwiftInterface: ZMUserSessionInterface {
    var conversationDirectory: ConversationDirectoryType { get }
}

extension ZMUserSession: UserSessionSwiftInterface {}
