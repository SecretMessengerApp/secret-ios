

import WireUtilities


private let zmLog = ZMSLog(tag: "share extension")


extension Error {

    func log(message: @autoclosure () -> String) {
        zmLog.error(message() + " — Error: \(self)")
    }

}
