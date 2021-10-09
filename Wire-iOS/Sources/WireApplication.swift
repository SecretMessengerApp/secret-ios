
import UIKit

final class WireApplication: UIApplication {
    
//    var shouldRegisterUserNotificationSettings: Bool {
//        return !(AutomationHelper.sharedHelper.skipFirstLoginAlerts || AutomationHelper.sharedHelper.disablePushNotificationAlert)
//    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        DebugAlert.showSendLogsMessage(
            message: "You have performed a shake motion, please confirm sending debug logs."
        )
    }
}

public func NSLocalizedString(_ key: String, tableName: String? = nil, bundle: Bundle = Bundle.main, value: String = "", comment: String) -> String
{
    key.localized
}
