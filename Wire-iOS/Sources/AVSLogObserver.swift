

import avs

private let zmLog = ZMSLog(tag: "AVS")

final class AVSLogObserver: AVSLogger {
    private var token: Any!
    
    init() {
        token = SessionManager.addLogger(self)
    }
    
    // MARK: - AVSLoggger
    
    func log(message: String) {
        zmLog.safePublic(SanitizedString(stringLiteral: message), level: .public)
    }
}
