//
import Foundation
import UserNotifications

extension UNUserNotificationCenter {

    /**
     * Checks asynchronously whether push notifications are disabled, that is,
     * when either the app is not registered for remote notifications or the
     * user did not authorize to receive remote/local notifications.
     *
     * - parameter handler: A block that accepts one boolean argument, whose
     * value is true iff the pushes are disabled.
     */
    func checkPushesDisabled(_ handler: @escaping (Bool) -> Void) {
        getNotificationSettings { settings in
            let pushesDisabled = settings.authorizationStatus == .denied
            handler(pushesDisabled)
        }
    }
}
